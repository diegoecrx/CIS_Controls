"#!/usr/bin/env bash
# 1.4.1 - Ensure bootloader password is set (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Inputs: must be provided by caller
: ""${GRUB_USERNAME:?ERROR: Set GRUB_USERNAME (e.g., export GRUB_USERNAME=root)}""
: ""${GRUB_PASSWORD_HASH:?ERROR: Set GRUB_PASSWORD_HASH (output of grub2-mkpasswd-pbkdf2)}""

STAMP=""$(date +%Y%m%d%H%M%S)""
CUSTOM=""/etc/grub.d/40_custom""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Determine GRUB config target (BIOS vs UEFI)
if [[ -d /sys/firmware/efi && -d /boot/efi/EFI ]]; then
  # Common OL7/RHEL7 UEFI vendor path is 'redhat' (Oracle also uses 'redhat' directory)
  if [[ -d /boot/efi/EFI/redhat ]]; then
    GRUB_CFG=""/boot/efi/EFI/redhat/grub.cfg""
  else
    # Fallback to first vendor dir found
    VENDOR_DIR=""$(find /boot/efi/EFI -mindepth 1 -maxdepth 1 -type d | head -n1 || true)""
    GRUB_CFG=""${VENDOR_DIR:-/boot/efi/EFI/redhat}/grub.cfg""
  fi
else
  GRUB_CFG=""/boot/grub2/grub.cfg""
fi

# 3) Backup existing files once
[[ -f ""$CUSTOM""   ]] && cp -p ""$CUSTOM""   ""${CUSTOM}.bak-${STAMP}""
[[ -f ""$GRUB_CFG"" ]] && cp -p ""$GRUB_CFG"" ""${GRUB_CFG}.bak-${STAMP}""

# 4) Ensure /etc/grub.d/40_custom contains superuser + password_pbkdf2
#    If entries exist, replace them; otherwise append.
install -m 0644 -o root -g root /dev/null ""$CUSTOM""
{
  echo '# This file is managed by CIS 1.4.1 hardening script'
  echo ""set superusers=\""$GRUB_USERNAME\""""
  echo ""password_pbkdf2 $GRUB_USERNAME $GRUB_PASSWORD_HASH""
} > ""$CUSTOM""

# 5) Harden permissions on 40_custom
chown root:root ""$CUSTOM""
chmod 0600 ""$CUSTOM""

# 6) Rebuild grub.cfg
if command -v grub2-mkconfig >/dev/null 2>&1; then
  grub2-mkconfig -o ""$GRUB_CFG"" >/dev/null
else
  echo ""ERROR: grub2-mkconfig not found."" >&2
  exit 1
fi

# 7) Verify
FAIL=0
grep -qE '^\s*set\s+superusers=' ""$CUSTOM"" || { echo ""FAIL: superusers not present in 40_custom""; FAIL=1; }
grep -qE '^\s*password_pbkdf2\s+' ""$CUSTOM"" || { echo ""FAIL: password_pbkdf2 not present in 40_custom""; FAIL=1; }
grep -q 'password_pbkdf2' ""$GRUB_CFG"" >/dev/null 2>&1 || { echo ""FAIL: grub.cfg does not reference password_pbkdf2""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: GRUB2 bootloader password configured for user '$GRUB_USERNAME' and persisted (CIS 1.4.1).""
  echo ""NOTE: To generate a hash: grub2-mkpasswd-pbkdf2  # then set GRUB_PASSWORD_HASH to the printed value.""
  exit 0
else
  exit 1
fi"
