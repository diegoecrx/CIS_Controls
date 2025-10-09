#!/bin/bash
# ID: 1.1.2_script.sh 1.1.17 Ensure separate partition exists for /home (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.2_script.sh
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
# Check if /home is on a separate partition
if mountpoint -q "/home"; then
  echo "/home is on a separate partition"
else
  echo "/home is not on a separate partition. Manual remediation required."
  result="pending"
fi

log_event "$result"
exit 0
