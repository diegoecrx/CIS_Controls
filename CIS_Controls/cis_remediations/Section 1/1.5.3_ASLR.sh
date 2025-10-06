"#!/usr/bin/env bash
# 1.5.3 - Ensure ASLR is enabled (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

SYSCTL_DROPIN=""/etc/sysctl.d/99-cis-aslr.conf""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Persist setting in sysctl.d drop-in
if [[ -f ""$SYSCTL_DROPIN"" && ! -f ""${SYSCTL_DROPIN}.bak-${STAMP}"" ]]; then
  cp -p ""$SYSCTL_DROPIN"" ""${SYSCTL_DROPIN}.bak-${STAMP}""
fi
install -m 0644 -o root -g root /dev/null ""$SYSCTL_DROPIN""
cat > ""$SYSCTL_DROPIN"" <<'EOF'
# CIS 1.5.3 - Enable Address Space Layout Randomization
kernel.randomize_va_space = 2
EOF

# 3) Apply to running kernel
sysctl -w kernel.randomize_va_space=2 >/dev/null

# 4) Verify runtime and persistence
FAIL=0
if [[ ""$(sysctl -n kernel.randomize_va_space 2>/dev/null)"" != ""2"" ]]; then
  echo ""FAIL: runtime kernel.randomize_va_space != 2""
  FAIL=1
fi
grep -qE '^\s*kernel\.randomize_va_space\s*=\s*2\s*$' ""$SYSCTL_DROPIN"" \
  || { echo ""FAIL: persistence not set in $SYSCTL_DROPIN""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: ASLR enabled (kernel.randomize_va_space=2) and persisted (CIS 1.5.3).""
  exit 0
else
  exit 1
fi"
