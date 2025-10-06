"#!/usr/bin/env bash
# 1.6.1.8 - Ensure the MCS Translation Service (mcstrans) is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""mcstrans""
SRV=""mcstransd.service""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Stop/disable/mask the service if present (idempotent)
if systemctl list-unit-files 2>/dev/null | grep -q ""^${SRV}""; then
  systemctl stop ""$SRV"" 2>/dev/null || true
  systemctl disable ""$SRV"" 2>/dev/null || true
  systemctl --now mask ""$SRV"" 2>/dev/null || true
fi

# 3) Remove the package if installed
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  yum -y remove ""$PKG"" || {
    echo ""FAIL: Unable to remove $PKG.""
    exit 1
  }
fi

# 4) Verify
FAIL=0

# Package must be absent
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  echo ""FAIL: Package still installed: $PKG""
  FAIL=1
fi

# If unit exists at all, it must be masked and inactive
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

# Binaries should not be present
for b in /usr/sbin/mcstransd /usr/bin/mcstransd; do
  [[ -x ""$b"" ]] && { echo ""FAIL: Binary still present: $b""; FAIL=1; }
done

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: mcstrans removed/disabled per CIS 1.6.1.8.""
  exit 0
else
  exit 1
fi"
