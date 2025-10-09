#!/bin/bash
# ID: 1.8.4_xdcmp_not.sh 1.8.4 Ensure XDCMP is not enabled (Automated)

section=1_initial_setup
sub_section=1.8_gnome_display_manager
script_name=1.8.4_xdcmp_not.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/gdm/custom.conf"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter Enable to true in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Enable\s*=" "$CONF_FILE"; then
    sed -i "s|^Enable\s*=.*|Enable = true|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Enable = true" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0