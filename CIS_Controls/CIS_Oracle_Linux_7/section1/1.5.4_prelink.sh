#!/bin/bash
# ID: 1.5.4_prelink_not_installed.sh 1.5.4 Ensure prelink is not installed (Automated)

section=1_initial_setup
sub_section=1.5_additional_process_hardening
script_name=1.5.4_prelink_not_installed.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE=""
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: yum remove prelink"
yum remove prelink || result="pending"


log_event "$result"
exit 0