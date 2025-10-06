"#!/usr/bin/env bash
# CIS 2.2.8 - Ensure FTP Server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""vsftpd""
UNITS=(vsftpd.service)
CONF_DIR=""/etc/vsftpd""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-vsftpd""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask service if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup configuration if present (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 4) Remove package (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Kill any lingering processes
pkill -TERM -x vsftpd 2>/dev/null || true
sleep 1
pkill -KILL -x vsftpd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

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
if pgrep -x vsftpd >/dev/null 2>&1; then
  echo ""FAIL: vsftpd process still running""
  FAIL=1
fi

# d) Optional: warn if port 21 is in use (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(21)$'; then
  echo ""NOTE: Port 21 is in use by another process; ensure no FTP server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: FTP server (vsftpd) not installed/running (CIS 2.2.8)""
  exit 0
else
  exit 1
fi"
