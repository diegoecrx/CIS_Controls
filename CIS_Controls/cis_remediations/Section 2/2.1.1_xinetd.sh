"#!/usr/bin/env bash
# CIS 2.1.1 - Ensure xinetd is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""xinetd""
SERVICE=""xinetd""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-${PKG}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) If installed, stop/disable and back up configs prior to removal
if rpm -q ""${PKG}"" &>/dev/null; then
  # Stop and disable service if it exists
  if systemctl list-unit-files | grep -qE ""^${SERVICE}\.service""; then
    systemctl stop ""${SERVICE}.service"" 2>/dev/null || true
    systemctl disable ""${SERVICE}.service"" 2>/dev/null || true
    systemctl mask ""${SERVICE}.service"" 2>/dev/null || true
  fi

  # Backup configuration if present
  [[ -f /etc/xinetd.conf ]] && cp -a /etc/xinetd.conf ""${BACKUP_DIR}/""
  [[ -d /etc/xinetd.d ]] && cp -a /etc/xinetd.d ""${BACKUP_DIR}/""

  # Remove package (idempotent)
  yum -y remove ""${PKG}"" >/dev/null
  systemctl daemon-reload || true
fi

# 3) Verification (runtime + persistence)
FAIL=0

# a) Package not installed
if rpm -q ""${PKG}"" &>/dev/null; then
  echo ""FAIL: Package '${PKG}' still installed""
  FAIL=1
fi

# b) Service unit absent or disabled/masked
if systemctl list-unit-files | grep -qE ""^${SERVICE}\.service""; then
  # Unit still exists — ensure it's disabled and not running
  if systemctl is-enabled ""${SERVICE}.service"" 2>/dev/null | grep -vqE 'disabled|masked'; then
    echo ""FAIL: ${SERVICE}.service enabled""
    FAIL=1
  fi
  if systemctl is-active ""${SERVICE}.service"" 2>/dev/null | grep -q '^active$'; then
    echo ""FAIL: ${SERVICE}.service running""
    FAIL=1
  fi
fi

# c) No running process
if pgrep -x ""${SERVICE}"" &>/dev/null; then
  echo ""FAIL: Process '${SERVICE}' still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: xinetd not installed/running (CIS 2.1.1)""
  exit 0
else
  exit 1
fi"
