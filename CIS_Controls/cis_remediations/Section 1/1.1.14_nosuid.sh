"#!/usr/bin/env bash
# 1.1.14 - Ensure /var/tmp partition includes the nosuid option
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1     # Level 2 profiles inherit Level 1 items
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Require /var/tmp to be a separate filesystem (per CIS order)
if ! findmnt -n /var/tmp >/dev/null 2>&1; then
  echo ""FAIL: /var/tmp is not a separate filesystem; cannot safely enforce 1.1.14.""
  echo ""HINT: First implement CIS 1.1.11 to create a separate /var/tmp.""
  exit 1
fi

# 3) Ensure fstab has nosuid on /var/tmp
if ! grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/var/tmp[[:space:]]+' ""$FSTAB""; then
  echo ""FAIL: No /var/tmp entry found in $FSTAB.""
  exit 1
fi

cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

# Update only the first non-comment line whose mountpoint is /var/tmp: add nosuid to the 4th field (options)
awk '
BEGIN { done=0 }
$0 !~ /^[[:space:]]*#/ && $2 == ""/var/tmp"" && done==0 {
  n=split($4,opts,"",""); has=0
  for(i=1;i<=n;i++) if (opts[i]==""nosuid"") has=1
  if (!has) {
    if ($4 == ""-"" || $4 == """") $4=""nosuid""; else $4=$4"",nosuid""
  }
  print $0; done=1; next
}
{ print $0 }
' OFS=""\t"" ""$FSTAB"" > ""${FSTAB}.new""

# Replace fstab if changed
if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then
  mv ""${FSTAB}.new"" ""$FSTAB""
else
  rm -f ""${FSTAB}.new""
fi

# 4) Remount /var/tmp with nosuid (runtime)
mount -o remount,nosuid /var/tmp 2>/dev/null || {
  echo ""ERROR: Failed to remount /var/tmp with nosuid.""
  exit 2
}

# 5) Verify runtime and persistence
FAIL=0
if ! findmnt -no OPTIONS /var/tmp | grep -qw nosuid; then
  echo ""FAIL: /var/tmp is not mounted with nosuid.""
  FAIL=1
fi
if ! grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/var/tmp[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]*nosuid[^[:space:]]*' ""$FSTAB""; then
  echo ""FAIL: /etc/fstab entry for /var/tmp does not include nosuid.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /var/tmp mounted with nosuid and persisted in $FSTAB (CIS 1.1.14).""
  exit 0
else
  exit 1
fi"
