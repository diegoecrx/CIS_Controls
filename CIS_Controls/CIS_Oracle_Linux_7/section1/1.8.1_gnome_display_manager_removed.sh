#!/bin/bash
# ID: 1.8.1_gnome_display_manager_removed.sh 1.8.1 Ensure GNOME Display Manager is removed (Manual)

section=1_initial_setup
sub_section=1.8_gnome_display_manager
script_name=1.8.1_gnome_display_manager_removed.sh
profile_app_server=2
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

echo "Executing: yum remove gdm"
yum remove gdm || result="pending"


log_event "$result"
exit 0