#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure the audit backlog limit is sufficient by adding audit_backlog_limit to the kernel command line.
# Filename: 4.1.2.4_audit_backlog_limit.sh
# Applicability: Level 2 for both Server and Workstation
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Default backlog size; adjust using BACKLOG_SIZE environment variable
BACKLOG_SIZE=${BACKLOG_SIZE:-8192}
cfg_file="/etc/default/grub"
[[ -f "$cfg_file" && ! -f "${cfg_file}.bak" ]] && cp "$cfg_file" "${cfg_file}.bak"

# Append audit_backlog_limit parameter if missing
if grep -q '^GRUB_CMDLINE_LINUX=' "$cfg_file"; then
  line=$(grep '^GRUB_CMDLINE_LINUX=' "$cfg_file")
  current=$(echo "$line" | cut -d'"' -f2)
  # Build parameter
  param="audit_backlog_limit=${BACKLOG_SIZE}"
  if [[ "$current" != *"audit_backlog_limit="* ]]; then
    new_cmdline="${current} ${param}"
    sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"${new_cmdline}\"/" "$cfg_file"
  fi
else
  echo "GRUB_CMDLINE_LINUX=\"audit_backlog_limit=${BACKLOG_SIZE}\"" >> "$cfg_file"
fi

# Determine grub.cfg location
if [[ -d /sys/firmware/efi ]]; then
  vendor_dir=$(ls -1 /boot/efi/EFI 2>/dev/null | head -n1 || true)
  if [[ -n "$vendor_dir" ]]; then
    grub_cfg="/boot/efi/EFI/${vendor_dir}/grub.cfg"
  else
    grub_cfg="/boot/efi/EFI/redhat/grub.cfg"
  fi
else
  grub_cfg="/boot/grub2/grub.cfg"
fi
[[ -f "$grub_cfg" && ! -f "${grub_cfg}.bak" ]] && cp "$grub_cfg" "${grub_cfg}.bak"
grub2-mkconfig -o "$grub_cfg" >/dev/null 2>&1 || true

# Verification
if grep -q "audit_backlog_limit=${BACKLOG_SIZE}" "$cfg_file"; then
  echo "OK: audit_backlog_limit set to ${BACKLOG_SIZE} (CIS 4.1.2.4)."
  exit 0
else
  echo "FAIL: audit_backlog_limit not set." >&2
  exit 1
fi