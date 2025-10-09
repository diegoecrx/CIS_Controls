#!/bin/bash
# ID: 1.6.1.7_setroubleshoot_not_installed.sh 1.6.1.7 Ensure SETroubleshoot is not installed (Automated)

section=1_initial_setup
sub_section=1.6_mandatory_access_control
script_name=1.6.1.7_setroubleshoot_not_installed.sh
profile_app_server=1
profile_app_workstation=N/A

CONF_FILE=""
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: yum remove setroubleshoot"
yum remove setroubleshoot || result="pending"


log_event "$result"
exit 0