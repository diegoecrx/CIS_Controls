#!/bin/bash
# ID: 1.1.21_removable_media_partitions.sh 1.1.13 Ensure /var/tmp partition includes the nodev option (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.21_removable_media_partitions.sh
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

echo "Executing: mount -o remount,nodev /var/tmp"
mount -o remount,nodev /var/tmp || result="pending"


log_event "$result"
exit 0