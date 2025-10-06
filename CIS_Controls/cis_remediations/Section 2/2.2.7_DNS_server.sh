"#!/usr/bin/env bash
# CIS 2.2.7 - Ensure DNS Server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove BIND server components. Avoid removing client/libs unless required.
PKGS=(bind bind-chroot)
UNITS=(named.service named-chroot.service)
CONF_FILES=(/etc/named.conf)
CONF_DIRS=(/etc/named /var/named)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-bind""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask BIND units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup configuration/state if present
for f in ""${CONF_FILES[@]}""; do
  [[ -f ""$f"" ]] && cp -a ""$f"" ""${BACKUP_DIR}/""
done
for d in ""${CONF_DIRS[@]}""; do
  [[ -d ""$d"" ]] && cp -a ""$d"" ""${BACKUP_DIR}/""
done

# 4) Remove server packages (idempotent)
to_remove=()
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done
if (( ${#to_remove[@]} > 0 )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Terminate any lingering named processes
pkill -TERM -x named 2>/dev/null || true
sleep 1
pkill -KILL -x named 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units not enabled/active if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    state=""$(systemctl is-enabled ""$u"" 2>/dev/null || true)""
    if [[ ""$state"" != ""disabled"" && ""$state"" != ""masked"" ]]; then
      echo ""FAIL: $u is enabled ($state)""
      FAIL=1
    fi
    if systemctl is-active ""$u"" >/dev/null 2>&1; then
      echo ""FAIL: $u is active""
      FAIL=1
    fi
  fi
done

# c) No running process
if pgrep -x named >/dev/null 2>&1; then
  echo ""FAIL: 'named' process still running""
  FAIL=1
fi

# d) Optional: warn if TCP/UDP 53 is in use (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(53)$'; then
  echo ""NOTE: Port 53 is in use by another process; ensure no DNS server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: DNS server (BIND) not installed/running (CIS 2.2.7)""
  exit 0
else
  exit 1
fi"
