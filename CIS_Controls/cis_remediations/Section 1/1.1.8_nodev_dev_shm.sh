"#!/usr/bin/env bash
# 1.1.8 - Ensure nodev option set on /dev/shm partition (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
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

# 2) Ensure /etc/fstab has a /dev/shm tmpfs entry with nodev (add line if missing)
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

if grep -Eq '^[[:space:]]*tmpfs[[:space:]]+/dev/shm[[:space:]]+tmpfs' ""$FSTAB""; then
  # Add nodev to 4th field if missing (preserve other options)
  awk '
    BEGIN { OFS=""\t"" }
    /^[[:space:]]*($|#)/ { print; next }
    $2==""/dev/shm"" && $3==""tmpfs"" {
      n=split($4,a,"",""); has=0
      for(i=1;i<=n;i++) if(a[i]==""nodev"") has=1
      if(!has){ if($4==""""||$4==""-"") $4=""nodev""; else $4=$4"",nodev"" }
      print; next
    }
    { print }
  ' ""$FSTAB"" > ""${FSTAB}.new""
else
  # Create a compliant entry (CIS-friendly defaults for OL7)
  {
    cat ""$FSTAB""
    echo -e ""tmpfs\t/dev/shm\ttmpfs\tdefaults,noexec,nodev,nosuid,seclabel\t0 0""
  } > ""${FSTAB}.new""
fi

if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then
  mv ""${FSTAB}.new"" ""$FSTAB""
else
  rm -f ""${FSTAB}.new""
fi

# 3) Remount runtime (CIS example remount includes noexec,nodev,nosuid)
mount -o remount,noexec,nodev,nosuid /dev/shm 2>/dev/null || mount /dev/shm || true

# 4) Verify runtime and persistence
FAIL=0

# Runtime must include nodev
if ! findmnt -n /dev/shm >/dev/null 2>&1; then
  echo ""FAIL: /dev/shm not mounted.""
  FAIL=1
else
  findmnt -no OPTIONS /dev/shm | grep -qw nodev || { echo ""FAIL: /dev/shm missing nodev at runtime.""; FAIL=1; }
fi

# Persistence in /etc/fstab must include nodev
if ! awk 'NF && $1 !~ /^#/ && $2==""/dev/shm"" && $3==""tmpfs"" {exit ($4 ~ /(^|,)nodev(,|$))?0:1} END{exit 1}' ""$FSTAB""; then
  echo ""FAIL: /etc/fstab entry for /dev/shm does not include nodev.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /dev/shm has nodev at runtime and is persisted in /etc/fstab (CIS 1.1.8).""
  exit 0
else
  exit 1
fi"
