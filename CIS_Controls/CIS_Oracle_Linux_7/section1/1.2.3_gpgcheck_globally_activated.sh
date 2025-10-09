#!/bin/bash
# ID: 1.2.3_gpgcheck_globally_activated.sh 1.2.3 Ensure gpgcheck is globally activated (Automated)

section=1_initial_setup
sub_section=1.2_configure_software_updates
script_name=1.2.3_gpgcheck_globally_activated.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/yum.conf"
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
