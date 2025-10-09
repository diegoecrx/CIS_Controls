#!/bin/bash
# ID: 1.7.4_permissions_etc_motd_are.sh 1.7.4 Ensure permissions on /etc/motd are configured (Automated)

section=1_initial_setup
sub_section=1.7_command_line_warning_banners
script_name=1.7.4_permissions_etc_motd_are.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/motd"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Executing: chown root:root /etc/motd"
chown root:root /etc/motd || result="pending"

echo "Executing: chmod u-x,go-wx /etc/motd"
chmod u-x,go-wx /etc/motd || result="pending"


log_event "$result"
exit 0