#!/bin/bash
# ID: 1.4.1_bootloader_password.sh 1.4.1 Ensure bootloader password is set (Automated)

section=1_initial_setup
sub_section=1.4_secure_boot_settings
script_name=1.4.1_bootloader_password.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/grub.d/01_users"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Implement remediation commands
result="success"
if grub2-setpassword; then
  echo "Executed: grub2-setpassword"
else
  echo "Failed: grub2-setpassword"
  result="pending"
fi
if grub2-mkpasswd-pbkdf2; then
  echo "Executed: grub2-mkpasswd-pbkdf2"
else
  echo "Failed: grub2-mkpasswd-pbkdf2"
  result="pending"
fi
if grub2-mkconfig -o /boot/grub2/grub.cfg; then
  echo "Executed: grub2-mkconfig -o /boot/grub2/grub.cfg"
else
  echo "Failed: grub2-mkconfig -o /boot/grub2/grub.cfg"
  result="pending"
fi

log_event "$result"
exit 0
