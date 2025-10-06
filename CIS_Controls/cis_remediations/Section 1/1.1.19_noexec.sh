"#!/usr/bin/env bash
# 1.1.19 - Ensure removable media partitions include noexec option
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1     # Level 2 profiles inherit Level 1 items
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# ---- Config: detection heuristics for ""removable media"" ----
# Match mountpoints like /media/*, /run/media/*, /mnt/floppy, /mnt/cdrom, or containing 'floppy'/'cdrom'
MP_REGEX='^(/media/|/run/media/|/mnt/(floppy|cdrom)|.*/(floppy|cdrom)(/|$))'
# Common removable filesystems (opt-in)
FS_REGEX='^(vfat|exfat|ntfs|iso9660|udf)$'

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Persist: add ""noexec"" to options in /etc/fstab for removable entries
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

awk -v mp_re=""$MP_REGEX"" -v fs_re=""$FS_REGEX"" '
BEGIN { changed=0; OFS=""\t"" }
# Pass comments/blank lines unchanged
/^[[:space:]]*($|#)/ { print; next }
{
  dev=$1; mp=$2; fs=$3; opts=$4; rest="""";
  for (i=5;i<=NF;i++) rest=rest"" "" $i;

  is_removable = (mp ~ mp_re) || (fs ~ fs_re)
  if (is_removable) {
    n=split(opts,a,"",""); has=0
    for (i=1;i<=n;i++) if (a[i]==""noexec"") has=1
    if (!has) {
      if (opts=="""" || opts==""-"") opts=""noexec""; else opts=opts"",noexec""
      changed=1
    }
    printf ""%s\t%s\t%s\t%s%s\n"", dev, mp, fs, opts, rest
    next
  }
  print
}
END { if (changed) { /* marker only */ } }
' ""$FSTAB"" > ""${FSTAB}.new""

if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then
  mv ""${FSTAB}.new"" ""$FSTAB""
else
  rm -f ""${FSTAB}.new""
fi

# 3) Runtime: remount currently mounted removable filesystems with noexec (best-effort)
#    We only touch mounts that match our heuristics and lack noexec
while IFS=',' read -r target fstype options; do
  [[ -z ""$target"" ]] && continue
  if [[ ""$target"" =~ $MP_REGEX || ""$fstype"" =~ $FS_REGEX ]]; then
    if ! grep -qw noexec <<< ""$options""; then
      mount -o remount,noexec ""$target"" 2>/dev/null || true
    fi
  fi
done < <(findmnt -rn -o TARGET,FSTYPE,OPTIONS | sed 's/ \+/,/g')

# 4) Verify
FAIL=0
MOUNT_MATCHES=0
FSTAB_MATCHES=0

# 4a) Verify runtime: all matching mounts include noexec
while IFS=',' read -r target fstype options; do
  [[ -z ""$target"" ]] && continue
  if [[ ""$target"" =~ $MP_REGEX || ""$fstype"" =~ $FS_REGEX ]]; then
    ((MOUNT_MATCHES++))
    if ! grep -qw noexec <<< ""$options""; then
      echo ""FAIL: runtime mount $target ($fstype) missing noexec.""
      FAIL=1
    fi
  fi
done < <(findmnt -rn -o TARGET,FSTYPE,OPTIONS | sed 's/ \+/,/g')

# 4b) Verify persistence: all matching fstab entries include noexec
#     Count entries that match our predicate and lack noexec
while read -r dev mp fs opts _rest; do
  [[ -z ""$dev"" || ""$dev"" =~ ^# ]] && continue
  if [[ ""$mp"" =~ $MP_REGEX || ""$fs"" =~ $FS_REGEX ]]; then
    ((FSTAB_MATCHES++))
    if ! grep -qw noexec <<< ""${opts:-}""; then
      echo ""FAIL: fstab entry for $mp ($fs) missing noexec.""
      FAIL=1
    fi
  fi
done < <(awk 'NF && $1 !~ /^#/' ""$FSTAB"")

# 4c) If there are no candidates at all, treat as not applicable (OK)
if [[ $MOUNT_MATCHES -eq 0 && $FSTAB_MATCHES -eq 0 && $FAIL -eq 0 ]]; then
  echo ""OK: No removable media partitions detected; control not applicable (CIS 1.1.19).""
  exit 0
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Removable media partitions mounted with noexec and persisted in $FSTAB (CIS 1.1.19).""
  exit 0
else
  exit 1
fi"
