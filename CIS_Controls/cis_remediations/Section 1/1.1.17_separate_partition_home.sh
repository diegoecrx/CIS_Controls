"#!/usr/bin/env bash
# 1.1.17 - Ensure separate partition exists for /home
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

HOME_SIZE=""${HOME_SIZE:-2G}""   # Used only when APPLY=1 and LVM is detected
FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Audit: is /home a separate mount?
if findmnt -n /home >/dev/null 2>&1; then
  echo ""OK: /home is a separate filesystem (CIS 1.1.17).""
  exit 0
fi

echo ""FAIL: /home is NOT a separate filesystem.""

# 3) Apply remediation only on request and only with LVM root
if [[ ""${APPLY:-0}"" -ne 1 ]]; then
  echo ""INFO: Set APPLY=1 HOME_SIZE=10G to migrate /home to a separate LVM LV (non-destructive).""
  echo ""NOTE: Prefer running with no interactive logins; migrating active $HOME may fail.""
  exit 1
fi

ROOT_DEV=""$(findmnt -no SOURCE / || true)""
if [[ ! ""$ROOT_DEV"" =~ ^/dev/mapper/ ]]; then
  echo ""ERROR: Root is not on LVM (found: ${ROOT_DEV:-unknown}). Aborting automated remediation.""
  exit 2
fi

VG_NAME=""$(lvs --noheadings -o vg_name ""$ROOT_DEV"" 2>/dev/null | xargs || true)""
if [[ -z ""$VG_NAME"" ]]; then
  echo ""ERROR: Unable to determine Volume Group for root ($ROOT_DEV).""
  exit 2
fi

# 4) Create LV, filesystem, mount to staging, and migrate content
LV_NAME=""home""
LV_PATH=""/dev/${VG_NAME}/${LV_NAME}""
if ! lvs ""$LV_PATH"" >/dev/null 2>&1; then
  lvcreate -L ""$HOME_SIZE"" -n ""$LV_NAME"" ""$VG_NAME""
fi

mkfs.ext4 -F -L home ""$LV_PATH""
mkdir -p /mnt/home.new
mount ""$LV_PATH"" /mnt/home.new

# Preserve ownerships/ACLs/attrs/xattrs
rsync -aAXS --numeric-ids /home/ /mnt/home.new/

# 5) Prepare switch-over with rollback safety
mv /home ""/home.old-${STAMP}""
mkdir -p /home

# 6) Persist in fstab and mount live
UUID=""$(blkid -s UUID -o value ""$LV_PATH"")""
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
sed -i '/[[:space:]]\/home[[:space:]]/d' ""$FSTAB""
echo ""UUID=${UUID}  /home  ext4  defaults  0 2"" >> ""$FSTAB""

mount /home
if ! mountpoint -q /home; then
  echo ""ERROR: Failed to mount new /home.""
  exit 2
fi

# Final sync and cleanup
rsync -aAXS --delete /mnt/home.new/ /home/
umount /mnt/home.new
rmdir /mnt/home.new || true

# 7) Verify
if findmnt -n /home >/dev/null 2>&1; then
  echo ""OK: /home migrated to separate LV ($LV_PATH) and persisted in $FSTAB (CIS 1.1.17).""
  echo ""Rollback tip: umount /home; remove its fstab line; mv /home.old-${STAMP} /home""
  exit 0
else
  echo ""ERROR: Verification failed; /home is not a separate mount.""
  exit 2
fi"
