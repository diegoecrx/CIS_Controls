#!/bin/bash
# ID: 1.1.23_disable_automounting.sh 1.1.15 Ensure separate partition exists for /var/log (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.23_disable_automounting.sh
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
# Check if /var/log is on a separate partition
if mountpoint -q "/var/log"; then
  echo "/var/log is on a separate partition"
else
  echo "/var/log is not on a separate partition. Manual remediation required."
  result="pending"
fi

log_event "$result"
exit 0
