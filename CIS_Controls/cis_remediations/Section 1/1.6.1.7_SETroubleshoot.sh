"#!/usr/bin/env bash
# 1.6.1.7 - Ensure SETroubleshoot is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=0

set -euo pipefail

# Packages and services commonly present on OL7
PKGS=(setroubleshoot setroubleshoot-server)
SRV=""setroubleshootd.service""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Stop/disable/mask service if it exists (idempotent)
if systemctl list-unit-files 2>/dev/null | grep -q ""^${SRV}""; then
  systemctl stop ""$SRV"" 2>/dev/null || true
  systemctl disable ""$SRV"" 2>/dev/null || true
  systemctl --now mask ""$SRV"" 2>/dev/null || true
fi

# 3) Remove packages if installed
if rpm -q ""${PKGS[@]}"" >/dev/null 2>&1; then
  yum -y remove ""${PKGS[@]}"" || {
    echo ""FAIL: Unable to remove SETroubleshoot packages.""
    exit 1
  }
fi

# 4) Verify
FAIL=0
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" >/dev/null 2>&1; then
    echo ""FAIL: Package still installed: $p""
    FAIL=1
  }
done

# If unit exists at all, ensure it’s masked/inactive
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
for b in /usr/bin/sealert /usr/sbin/setroubleshootd; do
  if [[ -x ""$b"" ]]; then
    echo ""FAIL: Binary still present: $b""
    FAIL=1
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: SETroubleshoot removed/disabled per CIS 1.6.1.7.""
  exit 0
else
  exit 1
fi"
