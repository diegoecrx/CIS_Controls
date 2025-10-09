#!/bin/bash
# ID: 1.7.5_permissions_etc_issue_are.sh 1.7.5 Ensure permissions on /etc/issue are configured (Automated)

section=1_initial_setup
sub_section=1.7_command_line_warning_banners
script_name=1.7.5_permissions_etc_issue_are.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/issue"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: chown root:root /etc/issue"
chown root:root /etc/issue || result="pending"

echo "Executing: chmod u-x,go-wx /etc/issue"
chmod u-x,go-wx /etc/issue || result="pending"


log_event "$result"
exit 0