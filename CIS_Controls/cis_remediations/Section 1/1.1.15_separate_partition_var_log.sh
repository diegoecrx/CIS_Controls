"#!/usr/bin/env bash
# 1.1.15 - Ensure separate partition exists for /var/log
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

VAR_LOG_SIZE=""${VAR_LOG_SIZE:-2G}""   # Used only when APPLY=1 and LVM is detected
FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Audit: is /var/log a separate mount?
if findmnt -n /var/log >/dev/null 2>&1; then
  echo ""OK: /var/log is a separate filesystem (CIS 1.1.15).""
  exit 0
fi

echo ""FAIL: /var/log is NOT a separate filesystem.""

# 3) Apply remediation only on request and only with LVM root
if [[ ""${APPLY:-0}"" -ne 1 ]]; then
  echo ""INFO: Set APPLY=1 VAR_LOG_SIZE=4G to migrate /var/log to a separate LVM LV (non-destructive).""
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
LV_NAME=""var_log""
LV_PATH=""/dev/${VG_NAME}/${LV_NAME}""
if ! lvs ""$LV_PATH"" >/dev/null 2>&1; then
  lvcreate -L ""$VAR_LOG_SIZE"" -n ""$LV_NAME"" ""$VG_NAME""
fi

mkfs.ext4 -F -L var_log ""$LV_PATH""
mkdir -p /mnt/var.log.new
mount ""$LV_PATH"" /mnt/var.log.new

# Preserve ownerships/ACLs/attrs/xattrs
rsync -aAXS --numeric-ids /var/log/ /mnt/var.log.new/

# 5) Prepare switch-over with rollback safety
mv /var/log ""/var/log.old-${STAMP}""
mkdir -p /var/log

# 6) Persist in fstab and mount live
UUID=""$(blkid -s UUID -o value ""$LV_PATH"")""
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
sed -i '/[[:space:]]\/var\/log[[:space:]]/d' ""$FSTAB""
echo ""UUID=${UUID}  /var/log  ext4  defaults  0 2"" >> ""$FSTAB""

mount /var/log
if ! mountpoint -q /var/log; then
  echo ""ERROR: Failed to mount new /var/log.""
  exit 2
fi

# Final sync and cleanup
rsync -aAXS --delete /mnt/var.log.new/ /var/log/
umount /mnt/var.log.new
rmdir /mnt/var.log.new || true

# 7) Verify
if findmnt -n /var/log >/dev/null 2>&1; then
  echo ""OK: /var/log migrated to separate LV ($LV_PATH) and persisted in $FSTAB (CIS 1.1.15).""
  echo ""Rollback tip: umount /var/log; remove its fstab line; mv /var/log.old-${STAMP} /var/log""
  exit 0
else
  echo ""ERROR: Verification failed; /var/log is not a separate mount.""
  exit 2
fi"
