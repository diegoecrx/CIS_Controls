#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure auditing for processes that start prior to auditd is enabled by adding audit=1 to the kernel command line.
# Filename: 4.1.1.3_audit_grub.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

cfg_file="/etc/default/grub"
# Backup the grub default configuration if no backup exists
if [[ -f "$cfg_file" && ! -f "${cfg_file}.bak" ]]; then
  cp "$cfg_file" "${cfg_file}.bak"
fi

# Ensure GRUB_CMDLINE_LINUX contains audit=1
if [[ -f "$cfg_file" ]]; then
  if grep -q '^GRUB_CMDLINE_LINUX=' "$cfg_file"; then
    line=$(grep '^GRUB_CMDLINE_LINUX=' "$cfg_file")
    current=$(echo "$line" | cut -d'"' -f2)
    if [[ "$current" != *"audit=1"* ]]; then
      new_cmdline="${current} audit=1"
      # Use sed to replace the entire line
      sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"${new_cmdline}\"/" "$cfg_file"
    fi
  else
    # If the variable does not exist, append it
    echo 'GRUB_CMDLINE_LINUX="audit=1"' >> "$cfg_file"
  fi
else
  echo "ERROR: $cfg_file does not exist" >&2
  exit 1
fi

# Determine the appropriate grub configuration path
if [[ -d /sys/firmware/efi ]]; then
  # Attempt to discover the vendor directory under EFI
  vendor_dir=$(ls -1 /boot/efi/EFI 2>/dev/null | head -n1 || true)
  if [[ -n "$vendor_dir" && -d "/boot/efi/EFI/$vendor_dir" ]]; then
    grub_cfg="/boot/efi/EFI/${vendor_dir}/grub.cfg"
  else
    # Fallback to common path
    grub_cfg="/boot/efi/EFI/redhat/grub.cfg"
  fi
else
  grub_cfg="/boot/grub2/grub.cfg"
fi

# Backup the grub.cfg prior to regeneration
if [[ -f "$grub_cfg" && ! -f "${grub_cfg}.bak" ]]; then
  cp "$grub_cfg" "${grub_cfg}.bak"
fi

# Regenerate the grub configuration
grub2-mkconfig -o "$grub_cfg" >/dev/null 2>&1 || true

# Verification: ensure audit=1 is present in the default configuration
if grep -q 'audit=1' "$cfg_file"; then
  echo "OK: audit=1 is configured in GRUB_CMDLINE_LINUX (CIS 4.1.1.3)."
  exit 0
else
  echo "FAIL: audit=1 is not set in GRUB_CMDLINE_LINUX." >&2
  exit 1
fi