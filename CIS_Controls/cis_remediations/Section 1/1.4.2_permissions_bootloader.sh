"#!/usr/bin/env bash
# 1.4.2 - Ensure permissions on bootloader config are configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""
FSTAB=""/etc/fstab""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Paths (BIOS and common files)
GRUB_BIOS_CFG=""/boot/grub2/grub.cfg""
GRUB_BIOS_USER=""/boot/grub2/user.cfg""

# 3) BIOS path: fix ownership and perms if files exist
fix_file_perms() {
  local f=""$1""
  [[ -f ""$f"" ]] || return 0
  chown root:root ""$f""
  chmod og-rwx ""$f""     # as per CIS (do not enforce specific u=)
}

fix_file_perms ""$GRUB_BIOS_CFG""
fix_file_perms ""$GRUB_BIOS_USER""

# 4) UEFI handling: if system is UEFI and /boot/efi is vfat, enforce fstab mount options
IS_UEFI=0
if [[ -d /sys/firmware/efi ]]; then
  if findmnt -nr -o FSTYPE /boot/efi 2>/dev/null | grep -qi '^vfat$'; then
    IS_UEFI=1
  fi
fi

if [[ $IS_UEFI -eq 1 ]]; then
  # Backup fstab once
  cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

  # Ensure /boot/efi vfat line exists; if not, we won't create a new device mapping (site-specific)
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/boot/efi[[:space:]]+vfat' ""$FSTAB""; then
    # Add/normalize umask=0027 and fmask=0077 into options field (4th column)
    awk '
      BEGIN { OFS=""\t"" }
      /^[[:space:]]*($|#)/ { print; next }
      $2==""/boot/efi"" && tolower($3)==""vfat"" {
        n=split($4, a, "",""); delete seen
        for(i=1;i<=n;i++) if (a[i]!="""") seen[a[i]]=1
        # Required options per CIS example
        req[1]=""umask=0027""; req[2]=""fmask=0077""; req[3]=""uid=0""; req[4]=""gid=0""
        # Keep existing options, then append any missing required ones
        opts=""""
        for(i=1;i<=n;i++) if (a[i]!="""") opts = (opts?opts"",""a[i]:a[i])
        for(i=1;i<=4;i++) if (!seen[req[i]]) opts = (opts?opts"",""req[i]:req[i])
        $4=opts
        print; next
      }
      { print }
    ' ""$FSTAB"" > ""${FSTAB}.new""
    if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then mv ""${FSTAB}.new"" ""$FSTAB""; else rm -f ""${FSTAB}.new""; fi

    # Try to remount with the new options (may still require reboot on some setups)
    mount -o remount /boot/efi 2>/dev/null || true
  else
    echo ""WARN: No /boot/efi vfat entry found in $FSTAB; cannot persist fmask/umask automatically.""
  fi
fi

# 5) Verify
FAIL=0

# BIOS files verification (if present)
verify_file() {
  local f=""$1""
  [[ -f ""$f"" ]] || return 0
  # Owner/group root:root
  if [[ ""$(stat -c '%u:%g' ""$f"")"" != ""0:0"" ]]; then
    echo ""FAIL: $f not owned by root:root""
    FAIL=1
  fi
  # Group/other must have no permissions
  local mode; mode=""$(stat -c '%a' ""$f"")""
  # Extract last two digits (g/o)
  local go=""${mode: -2}""
  if [[ ""$go"" != ""00"" ]]; then
    echo ""FAIL: $f group/other permissions not restricted (mode $mode)""
    FAIL=1
  fi
}

verify_file ""$GRUB_BIOS_CFG""
verify_file ""$GRUB_BIOS_USER""

# UEFI fstab verification (if applicable)
if [[ $IS_UEFI -eq 1 ]]; then
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/boot/efi[[:space:]]+vfat' ""$FSTAB""; then
    # Require fmask=0077 and umask=0027 in fstab options
    if ! awk 'NF && $1 !~ /^#/ && $2==""/boot/efi"" && tolower($3)==""vfat"" {exit ($4 ~ /(^|,)fmask=0077(,|$)/)?0:1}' ""$FSTAB""; then
      echo ""FAIL: /etc/fstab /boot/efi entry missing fmask=0077""
      FAIL=1
    fi
    if ! awk 'NF && $1 !~ /^#/ && $2==""/boot/efi"" && tolower($3)==""vfat"" {exit ($4 ~ /(^|,)umask=0027(,|$)/)?0:1}' ""$FSTAB""; then
      echo ""FAIL: /etc/fstab /boot/efi entry missing umask=0027""
      FAIL=1
    fi
    # Runtime advisory (best effort)
    if findmnt -nr -o OPTIONS /boot/efi | grep -q 'fmask=0077'; then
      :
    else
      echo ""INFO: /boot/efi runtime does not show fmask=0077; a reboot may be required.""
    fi
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Bootloader config permissions secured (CIS 1.4.2).""
  exit 0
else
  exit 1
fi"
