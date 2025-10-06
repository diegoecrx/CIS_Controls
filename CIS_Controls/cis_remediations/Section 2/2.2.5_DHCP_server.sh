"#!/usr/bin/env bash
# CIS 2.2.5 - Ensure DHCP Server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Note:
# - Target only DHCP *server* packages. Do NOT remove client components.
PKGS_CANDIDATES=(dhcp dhcp-server)          # OL7 typically uses 'dhcp' for dhcpd
UNITS=(dhcpd.service dhcpd6.service)
CONF_DIR=""/etc/dhcp""
SYSCONF=""/etc/sysconfig/dhcpd""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-dhcpd""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask DHCP server units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup server configuration (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""
[[ -f ""$SYSCONF"" ]] && cp -a ""$SYSCONF"" ""${BACKUP_DIR}/""

# 4) Remove DHCP server packages (idempotent)
to_remove=()
for p in ""${PKGS_CANDIDATES[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done
if (( ${#to_remove[@]} )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Ensure no lingering dhcpd processes
pkill -TERM -x dhcpd 2>/dev/null || true
sleep 1
pkill -KILL -x dhcpd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS_CANDIDATES[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units not enabled/active if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    if systemctl is-enabled ""$u"" &>/dev/null && [[ ""$(systemctl is-enabled ""$u"" 2>/dev/null)"" != ""masked"" && ""$(systemctl is-enabled ""$u"" 2>/dev/null)"" != ""disabled"" ]]; then
      echo ""FAIL: $u is enabled""
      FAIL=1
    fi
    if systemctl is-active ""$u"" &>/dev/null; then
      echo ""FAIL: $u is active""
      FAIL=1
    fi
  fi
done

# c) No running dhcpd process
if pgrep -x dhcpd >/dev/null 2>&1; then
  echo ""FAIL: dhcpd process still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: DHCP server not installed/running (CIS 2.2.5)""
  exit 0
else
  exit 1
fi"
