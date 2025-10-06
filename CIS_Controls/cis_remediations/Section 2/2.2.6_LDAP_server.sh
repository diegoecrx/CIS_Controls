"#!/usr/bin/env bash
# CIS 2.2.6 - Ensure LDAP server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG_PATTERN='openldap-servers*'
PKGS=(openldap-servers openldap-servers-sql)
UNIT=""slapd.service""
CONF_DIR=""/etc/openldap""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-openldap""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask slapd if present
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  systemctl stop ""${UNIT}"" 2>/dev/null || true
  systemctl disable ""${UNIT}"" 2>/dev/null || true
  systemctl mask ""${UNIT}"" 2>/dev/null || true
fi
systemctl daemon-reload || true

# 3) Backup LDAP server configuration (before removal)
if [[ -d ""$CONF_DIR"" ]]; then
  # Common locations: /etc/openldap/slapd.d (cn=config) and /etc/openldap/slapd.conf (legacy)
  [[ -d ""${CONF_DIR}/slapd.d"" ]] && cp -a ""${CONF_DIR}/slapd.d"" ""${BACKUP_DIR}/""
  [[ -f ""${CONF_DIR}/slapd.conf"" ]] && cp -a ""${CONF_DIR}/slapd.conf"" ""${BACKUP_DIR}/""
fi

# 4) Remove OpenLDAP server packages (idempotent)
to_remove=()
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done

# Also catch any other matching server subpackages
mapfile -t extra_pkgs < <(rpm -qa ""${PKG_PATTERN}"" 2>/dev/null || true)
if (( ${#extra_pkgs[@]} )); then
  for ep in ""${extra_pkgs[@]}""; do
    if ! printf '%s\n' ""${to_remove[@]}"" | grep -qx ""$ep""; then
      to_remove+=(""$ep"")
    fi
  done
fi

if (( ${#to_remove[@]} )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Terminate any lingering slapd processes
pkill -TERM -x slapd 2>/dev/null || true
sleep 1
pkill -KILL -x slapd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
if rpm -qa ""${PKG_PATTERN}"" >/dev/null 2>&1 && [[ -n ""$(rpm -qa ""${PKG_PATTERN}"")"" ]]; then
  echo ""FAIL: One or more OpenLDAP server packages still installed: $(rpm -qa ""${PKG_PATTERN}"" | tr '\n' ' ')""
  FAIL=1
fi
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Unit not enabled/active if present
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  state=""$(systemctl is-enabled ""${UNIT}"" 2>/dev/null || true)""
  if [[ ""$state"" != ""disabled"" && ""$state"" != ""masked"" ]]; then
    echo ""FAIL: ${UNIT} is enabled ($state)""
    FAIL=1
  fi
  if systemctl is-active ""${UNIT}"" >/dev/null 2>&1; then
    echo ""FAIL: ${UNIT} is active""
    FAIL=1
  fi
fi

# c) No running slapd process
if pgrep -x slapd >/dev/null 2>&1; then
  echo ""FAIL: slapd process still running""
  FAIL=1
fi

# d) Optional: nothing listening on 389/636 (informational, not a hard fail)
if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE '(:|\.)(389|636)$'; then
  echo ""NOTE: A process is listening on TCP 389/636; ensure it is not an LDAP server.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: LDAP server not installed/running (CIS 2.2.6)""
  exit 0
else
  exit 1
fi"
