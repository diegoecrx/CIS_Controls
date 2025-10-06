"#!/usr/bin/env bash
# 1.1.7 - Ensure noexec option set on /dev/shm partition (Oracle Linux 7)
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

# 2) Ensure /etc/fstab has a /dev/shm tmpfs entry with noexec (add line if missing)
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

if grep -Eq '^[[:space:]]*tmpfs[[:space:]]+/dev/shm[[:space:]]+tmpfs' ""$FSTAB""; then
  # Add noexec to 4th field if missing (preserve other options)
  awk '
    BEGIN { OFS=""\t"" }
    /^[[:space:]]*($|#)/ { print; next }
    $2==""/dev/shm"" && $3==""tmpfs"" {
      n=split($4,a,"",""); has=0
      for(i=1;i<=n;i++) if(a[i]==""noexec"") has=1
      if(!has){ if($4==""""||$4==""-"") $4=""noexec""; else $4=$4"",noexec"" }
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

# 3) Remount runtime (CIS example includes nodev,nosuid too; harmless and recommended)
mount -o remount,noexec,nodev,nosuid /dev/shm 2>/dev/null || mount /dev/shm || true

# 4) Verify runtime and persistence
FAIL=0

# Runtime must include noexec
if ! findmnt -n /dev/shm >/dev/null 2>&1; then
  echo ""FAIL: /dev/shm not mounted.""
  FAIL=1
else
  findmnt -no OPTIONS /dev/shm | grep -qw noexec || { echo ""FAIL: /dev/shm missing noexec at runtime.""; FAIL=1; }
fi

# Persistence in /etc/fstab must include noexec
if ! awk 'NF && $1 !~ /^#/ && $2==""/dev/shm"" && $3==""tmpfs"" {exit ($4 ~ /(^|,)noexec(,|$))?0:1} END{exit 1}' ""$FSTAB""; then
  echo ""FAIL: /etc/fstab entry for /dev/shm does not include noexec.""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /dev/shm has noexec at runtime and is persisted in /etc/fstab (CIS 1.1.7).""
  exit 0
else
  exit 1
fi"
