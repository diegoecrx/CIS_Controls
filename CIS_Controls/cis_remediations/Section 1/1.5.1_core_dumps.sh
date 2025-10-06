"#!/usr/bin/env bash
# 1.5.1 - Ensure core dumps are restricted (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""

# Files/paths
LIMITS_DROPIN=""/etc/security/limits.d/99-cis-core.conf""
SYSCTL_DROPIN=""/etc/sysctl.d/99-cis-core.conf""
COREDUMP_DIR=""/etc/systemd/coredump.conf.d""
COREDUMP_DROPIN=""${COREDUMP_DIR}/99-cis.conf""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) limits.conf: disable core dumps for all users (hard limit)
install -m 0644 -o root -g root /dev/null ""$LIMITS_DROPIN""
if ! grep -qE '^\*\s+hard\s+core\s+0\s*$' ""$LIMITS_DROPIN""; then
  cp -p ""$LIMITS_DROPIN"" ""${LIMITS_DROPIN}.bak-${STAMP}"" || true
  printf ""* hard core 0\n"" > ""$LIMITS_DROPIN""
fi

# 3) sysctl: fs.suid_dumpable = 0 (persist + runtime)
install -m 0644 -o root -g root /dev/null ""$SYSCTL_DROPIN""
if ! grep -qE '^\s*fs\.suid_dumpable\s*=\s*0\s*$' ""$SYSCTL_DROPIN""; then
  cp -p ""$SYSCTL_DROPIN"" ""${SYSCTL_DROPIN}.bak-${STAMP}"" || true
  printf ""fs.suid_dumpable = 0\n"" > ""$SYSCTL_DROPIN""
fi
# Apply to running kernel
sysctl -w fs.suid_dumpable=0 >/dev/null

# 4) systemd-coredump (if present): disable storage and size
COREDUMP_PRESENT=0
if systemctl list-unit-files 2>/dev/null | grep -q '^systemd-coredump@\.service'; then
  COREDUMP_PRESENT=1
elif command -v coredumpctl >/dev/null 2>&1 || [[ -f /etc/systemd/coredump.conf ]]; then
  COREDUMP_PRESENT=1
fi

if [[ $COREDUMP_PRESENT -eq 1 ]]; then
  mkdir -p ""$COREDUMP_DIR""
  install -m 0644 -o root -g root /dev/null ""$COREDUMP_DROPIN""
  cp -p ""$COREDUMP_DROPIN"" ""${COREDUMP_DROPIN}.bak-${STAMP}"" 2>/dev/null || true
  cat > ""$COREDUMP_DROPIN"" <<'EOF'
[Coredump]
# CIS 1.5.1: disable systemd-coredump storage
Storage=none
ProcessSizeMax=0
EOF
  systemctl daemon-reload
fi

# 5) Verify
FAIL=0

# limits drop-in present and correct
grep -qE '^\*\s+hard\s+core\s+0\s*$' ""$LIMITS_DROPIN"" || { echo ""FAIL: limits hard core 0 not set in $LIMITS_DROPIN""; FAIL=1; }

# sysctl runtime and persistence
[[ ""$(sysctl -n fs.suid_dumpable 2>/dev/null)"" == ""0"" ]] || { echo ""FAIL: fs.suid_dumpable runtime != 0""; FAIL=1; }
grep -qE '^\s*fs\.suid_dumpable\s*=\s*0\s*$' ""$SYSCTL_DROPIN"" || { echo ""FAIL: fs.suid_dumpable not persisted in $SYSCTL_DROPIN""; FAIL=1; }

# coredump config (only if present)
if [[ $COREDUMP_PRESENT -eq 1 ]]; then
  grep -qE '^\s*Storage\s*=\s*none\s*$' ""$COREDUMP_DROPIN"" || { echo ""FAIL: Storage=none not set in $COREDUMP_DROPIN""; FAIL=1; }
  grep -qE '^\s*ProcessSizeMax\s*=\s*0\s*$' ""$COREDUMP_DROPIN"" || { echo ""FAIL: ProcessSizeMax=0 not set in $COREDUMP_DROPIN""; FAIL=1; }
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Core dumps restricted (limits, sysctl, and systemd-coredump where applicable) per CIS 1.5.1.""
  echo ""NOTE: PAM limits apply at next login/session. Existing sessions may still have previous ulimit values.""
  exit 0
else
  exit 1
fi"
