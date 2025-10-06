"#!/usr/bin/env bash
# 1.8.1 - Ensure GNOME Display Manager (gdm) is removed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=0

set -euo pipefail

SRV=""gdm.service""
PKG=""gdm""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Stop/disable/mask gdm if the unit exists
if systemctl list-unit-files 2>/dev/null | grep -q ""^${SRV}""; then
  systemctl stop ""$SRV"" 2>/dev/null || true
  systemctl disable ""$SRV"" 2>/dev/null || true
  systemctl --now mask ""$SRV"" 2>/dev/null || true
fi

# 3) Optional: ensure the system does not boot to graphical.target
#    (harmless if already multi-user)
if systemctl get-default 2>/dev/null | grep -q '^graphical\.target$'; then
  systemctl set-default multi-user.target
fi

# 4) Remove gdm package if installed
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  yum -y remove ""$PKG""
fi

# 5) Verify
FAIL=0
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  echo ""FAIL: gdm package still installed.""
  FAIL=1
fi

if systemctl list-unit-files 2>/dev/null | grep -q ""^${SRV}""; then
  if ! systemctl is-enabled ""$SRV"" 2>/dev/null | grep -q '^masked$'; then
    echo ""FAIL: $SRV is not masked.""
    FAIL=1
  fi
  if systemctl is-active ""$SRV"" 2>/dev/null; then
    echo ""FAIL: $SRV is still active.""
    FAIL=1
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: GNOME Display Manager removed/disabled per CIS 1.8.1.""
  exit 0
else
  exit 1
fi"
