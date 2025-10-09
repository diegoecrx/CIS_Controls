#!/bin/bash
# ID: 1.6.1.2_selinux_not_in_bootloader.sh 1.6.1.2 Ensure SELinux is not disabled in bootloader configuration (Automated)

section=1_initial_setup
sub_section=1.6_mandatory_access_control
script_name=1.6.1.2_selinux_not_in_bootloader.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/default/grub"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter GRUB_CMDLINE_LINUX_DEFAULT to "quiet" in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT\s*=" "$CONF_FILE"; then
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT\s*=.*|GRUB_CMDLINE_LINUX_DEFAULT = "quiet"|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "GRUB_CMDLINE_LINUX_DEFAULT = "quiet"" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter GRUB_CMDLINE_LINUX to "" in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^GRUB_CMDLINE_LINUX\s*=" "$CONF_FILE"; then
    sed -i "s|^GRUB_CMDLINE_LINUX\s*=.*|GRUB_CMDLINE_LINUX = ""|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "GRUB_CMDLINE_LINUX = """ >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0