#!/bin/bash
# ID: 1.4.2_permissions_bootloader_config_are.sh 1.4.2 Ensure permissions on bootloader config are configured (Automated)

section=1_initial_setup
sub_section=1.4_secure_boot_settings
script_name=1.4.2_permissions_bootloader_config_are.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/fstab"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: chown root:root /boot/grub2/grub.cfg"
chown root:root /boot/grub2/grub.cfg || result="pending"

echo "Executing: chmod og-rwx /boot/grub2/grub.cfg"
chmod og-rwx /boot/grub2/grub.cfg || result="pending"


log_event "$result"
exit 0