#!/bin/bash
# ID: 1.8.3_last_logged_in_display.sh 1.8.3 Ensure last logged in user display is disabled (Automated)

section=1_initial_setup
sub_section=1.8_gnome_display_manager
script_name=1.8.3_last_logged_in_display.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/dconf/profile/gdm"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter disable-user-list to true in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^disable-user-list\s*=" "$CONF_FILE"; then
    sed -i "s|^disable-user-list\s*=.*|disable-user-list = true|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "disable-user-list = true" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0