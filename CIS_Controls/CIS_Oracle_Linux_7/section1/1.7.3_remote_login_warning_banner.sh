#!/bin/bash
# ID: 1.7.3_remote_login_warning_banner.sh 1.7.3 Ensure remote login warning banner is configured properly (Automated)

section=1_initial_setup
sub_section=1.7_command_line_warning_banners
script_name=1.7.3_remote_login_warning_banner.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/issue.net"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: echo \"Authorized uses only. All activity may be monitored and reported.\" >"
echo "Authorized uses only. All activity may be monitored and reported." > || result="pending"


log_event "$result"
exit 0