#!/bin/bash
# ID: 1.1.19_removable_media_partitions_include.sh 1.1.11 Ensure separate partition exists for /var/tmp (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.19_removable_media_partitions_include.sh
profile_app_server=2
profile_app_workstation=2

CONF_FILE="/etc/fstab"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Implement remediation commands
result="success"
# Check if /var/tmp is on a separate partition
if mountpoint -q "/var/tmp"; then
  echo "/var/tmp is on a separate partition"
else
  echo "/var/tmp is not on a separate partition. Manual remediation required."
  result="pending"
fi

log_event "$result"
exit 0
