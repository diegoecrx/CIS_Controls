"#!/usr/bin/env bash
# 1.6.1.3 - Ensure SELinux policy is configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/selinux/config""
STAMP=""$(date +%Y%m%d%H%M%S)""
TARGET_POLICY=""targeted""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Sanity: Ensure file exists (package 1.6.1.1 should have created it, but be defensive)
[[ -f ""$CONF"" ]] || install -m 0644 -o root -g root /dev/null ""$CONF""

# 3) Backup once per run
cp -p ""$CONF"" ""${CONF}.bak-${STAMP}""

# 4) Set SELINUXTYPE=<targeted> (preserve comments/other keys)
awk -v tgt=""$TARGET_POLICY"" '
  BEGIN{set=0}
  /^[[:space:]]*SELINUXTYPE[[:space:]]*=/ {
    print ""SELINUXTYPE="" tgt; set=1; next
  }
  { print }
  END{
    if (set==0) print ""SELINUXTYPE="" tgt
  }
' ""$CONF"" > ""${CONF}.new""
mv ""${CONF}.new"" ""$CONF""

# 5) Verify persistence and (best-effort) runtime
FAIL=0

# 5a) Persistence
grep -Eq '^[[:space:]]*SELINUXTYPE[[:space:]]*=[[:space:]]*targeted[[:space:]]*$' ""$CONF"" \
  || { echo ""FAIL: /etc/selinux/config does not set SELINUXTYPE=targeted""; FAIL=1; }

# 5b) Runtime (informational): check loaded policy if sestatus is available
if command -v sestatus >/dev/null 2>&1; then
  if ! sestatus | awk -F': *' '/Loaded policy name/{exit ($2==""targeted"")?0:1}'; then
    echo ""INFO: Loaded policy is not 'targeted'. A reboot or policy reload may be required to apply the change.""
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: SELINUXTYPE=targeted configured in $CONF (CIS 1.6.1.3).""
  exit 0
else
  exit 1
fi"
