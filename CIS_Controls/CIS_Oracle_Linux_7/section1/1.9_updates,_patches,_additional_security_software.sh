#!/bin/bash
# ID: 1.9_updates_patches_and_additional.sh 1.9 Ensure updates, patches, and additional security software are installed (Manual)

section=1_initial_setup
sub_section=1.8_gnome_display_manager
script_name=1.9_updates_patches_and_additional.sh
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

echo "Executing: yum update"
yum update || result="pending"


log_event "$result"
exit 0