"#!/usr/bin/env bash
# CIS 1.1.10 - Ensure separate partition exists for /var
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# --- Settings ---
VAR_SIZE=""${VAR_SIZE:-2G}""     # Used only when APPLY=1 and LVM is detected
FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# --- Require root ---
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# --- Audit: is /var a separate mount? ---
if findmnt -n /var >/dev/null 2>&1; then
  # /var is a mount point (separate FS)
  echo ""OK: /var is a separate filesystem (CIS 1.1.10).""
  exit 0
fi

echo ""FAIL: /var is NOT a separate filesystem.""

# --- Apply remediation only on request and only with LVM root ---
if [[ ""${APPLY:-0}"" -ne 1 ]]; then
  echo ""INFO: Set APPLY=1 to migrate /var to a separate LVM logical volume (non-destructive).""
  exit 1
fi

# Detect root LV and VG
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

# Check free space
if ! vgs ""$VG_NAME"" >/dev/null 2>&1; then
  echo ""ERROR: Volume Group '$VG_NAME' not found.""
  exit 2
fi

# Create LV, filesystem, mount, and migrate
LV_NAME=""var""
LV_PATH=""/dev/${VG_NAME}/${LV_NAME}""
if ! lvs ""$LV_PATH"" >/dev/null 2>&1; then
  lvcreate -L ""$VAR_SIZE"" -n ""$LV_NAME"" ""$VG_NAME""
fi

mkfs.ext4 -F -L var ""$LV_PATH""
mkdir -p /mnt/var.new
mount ""$LV_PATH"" /mnt/var.new

rsync -aAXS --numeric-ids /var/ /mnt/var.new/

# Prepare switch-over
mv /var ""/var.old-${STAMP}""
mkdir /var

# Persist in fstab and mount
UUID=""$(blkid -s UUID -o value ""$LV_PATH"")""
grep -qE ""[[:space:]]/var[[:space:]]"" ""$FSTAB"" && sed -i.bak ""$FSTAB"" -e '/[[:space:]]\/var[[:space:]]/d'
echo ""UUID=${UUID}  /var  ext4  defaults  0 2"" >> ""$FSTAB""

mount /var
mountpoint -q /var || { echo ""ERROR: Failed to mount new /var.""; exit 2; }

# Final sync and verification
rsync -aAXS --delete /mnt/var.new/ /var/
umount /mnt/var.new
rmdir /mnt/var.new || true

# Verify
if findmnt -n /var >/dev/null 2>&1; then
  echo ""OK: /var migrated to separate LV ($LV_PATH) and persisted in $FSTAB (CIS 1.1.10).""
  echo ""Rollback tip: umount /var; remove its fstab line; mv /var.old-${STAMP} /var""
  exit 0
else
  echo ""ERROR: Verification failed; /var is not a separate mount.""
  exit 2
fi"
