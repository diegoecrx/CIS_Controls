"#!/usr/bin/env bash
# CIS 2.2.4 - Ensure CUPS is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=0

set -euo pipefail

PKGS=(cups cups-client cups-lpd)
UNITS=(cups.service cups.socket cups.path)
CONF_DIR=""/etc/cups""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-cups""

# 1) Require root
[[ $EUID -ne 0 ]] && { echo ""ERROR: Run as root."" >&2; exit 1; }

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask CUPS-related systemd units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup configuration (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 4) Remove CUPS packages (idempotent; primary CIS target is 'cups')
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

# 5) Kill any lingering cupsd processes
pkill -TERM -x cupsd 2>/dev/null || true
sleep 1
pkill -KILL -x cupsd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units absent or not enabled/active
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

# c) No running cupsd process
if pgrep -x cupsd >/dev/null 2>&1; then
  echo ""FAIL: cupsd process still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: CUPS not installed/running (CIS 2.2.4)""
  exit 0
else
  exit 1
fi"
