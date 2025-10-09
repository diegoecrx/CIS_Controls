#!/bin/bash
# ID: 1.1.5_script.sh 1.1.20 Ensure nodev option set on removable media partitions (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.5_script.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/fstab"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Implement remediation commands
result="success"
echo "Manual remediation required: see CIS benchmark documentation."
result="pending"

log_event "$result"
exit 0
