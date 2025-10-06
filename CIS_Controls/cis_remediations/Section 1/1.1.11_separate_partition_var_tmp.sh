"#!/usr/bin/env bash
# CIS 1.1.11 - Ensure separate partition exists for /var/tmp (not tmpfs)
# Flags (metadata only; not enforced here)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# --- Settings ---
VAR_TMP_SIZE=""${VAR_TMP_SIZE:-1G}""   # Used only when APPLY=1 and LVM is detected
FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""

# --- Require root ---
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# --- Audit state ---
# 1) Is /var/tmp a distinct mount?
if findmnt -n /var/tmp >/dev/null 2>&1; then
  FSTYPE=""$(findmnt -n -o FSTYPE /var/tmp || echo unknown)""
  # 2) It must NOT be tmpfs
  if [[ ""$FSTYPE"" == ""tmpfs"" ]]; then
    echo ""FAIL: /var/tmp is tmpfs (CIS 1.1.11 requires a persistent disk-backed FS).""
    NEEDS_REMEDIATION=1
  else
    echo ""OK: /var/tmp is a separate mount with fstype='$FSTYPE' (CIS 1.1.11).""
    exit 0
  fi
else
  echo ""FAIL: /var/tmp is NOT a separate filesystem.""
  NEEDS_REMEDIATION=1
fi

# --- Stop here if not applying changes ---
if [[ ""${APPLY:-0}"" -ne 1 ]]; then
  echo ""INFO: Set APPLY=1 to create a persistent, separate /var/tmp (LVM required).""
  exit 1
fi

# --- Remediation path (LVM root only) ---
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

# Create LV if missing
LV_NAME=""var_tmp""
LV_PATH=""/dev/${VG_NAME}/${LV_NAME}""
if ! lvs ""$LV_PATH"" >/dev/null 2>&1; then
  lvcreate -L ""$VAR_TMP_SIZE"" -n ""$LV_NAME"" ""$VG_NAME""
fi

# Create filesystem and mount to staging
mkfs.ext4 -F -L var_tmp ""$LV_PATH""
mkdir -p /mnt/var.tmp.new
mount ""$LV_PATH"" /mnt/var.tmp.new

# Preserve current content and sticky bit semantics
# /var/tmp is expected to persist across reboots; copy content if any
rsync -aAXS --numeric-ids /var/tmp/ /mnt/var.tmp.new/ 2>/dev/null || true

# Prepare switch-over (keep rollback)
mv /var/tmp ""/var/tmp.old-${STAMP}""
mkdir -p /var/tmp
chmod 1777 /var/tmp
chown root:root /var/tmp

# Update /etc/fstab: ensure not tmpfs and point to the new LV by UUID
UUID=""$(blkid -s UUID -o value ""$LV_PATH"")""
# Remove any existing /var/tmp lines (including tmpfs or bind mounts)
if grep -qE ""[[:space:]]/var/tmp[[:space:]]"" ""$FSTAB""; then
  cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
  sed -i '/[[:space:]]\/var\/tmp[[:space:]]/d' ""$FSTAB""
fi
echo ""UUID=${UUID}  /var/tmp  ext4  defaults  0 2"" >> ""$FSTAB""

# Mount new /var/tmp
mount /var/tmp
mountpoint -q /var/tmp || { echo ""ERROR: Failed to mount new /var/tmp.""; exit 2; }

# Final sync and cleanup
rsync -aAXS --delete /mnt/var.tmp.new/ /var/tmp/
umount /mnt/var.tmp.new
rmdir /mnt/var.tmp.new || true

# Enforce sticky bit and ownership
chmod 1777 /var/tmp
chown root:root /var/tmp

# Verify
if findmnt -n /var/tmp >/dev/null 2>&1; then
  FSTYPE_NEW=""$(findmnt -n -o FSTYPE /var/tmp || echo unknown)""
  if [[ ""$FSTYPE_NEW"" == ""tmpfs"" ]]; then
    echo ""ERROR: /var/tmp is still tmpfs after remediation.""
    exit 2
  fi
  echo ""OK: /var/tmp migrated to separate LV ($LV_PATH) fstype='$FSTYPE_NEW' and persisted in $FSTAB (CIS 1.1.11).""
  echo ""Rollback tip: umount /var/tmp; remove its fstab line; mv /var/tmp.old-${STAMP} /var/tmp""
  exit 0
else
  echo ""ERROR: Verification failed; /var/tmp is not a separate mount.""
  exit 2
fi"
