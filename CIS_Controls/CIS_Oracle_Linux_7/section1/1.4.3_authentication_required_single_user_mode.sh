#!/bin/bash
# ID: 1.4.3_authentication_required_for_single.sh 1.4.3 Ensure authentication required for single user mode (Automated)

section=1_initial_setup
sub_section=1.4_secure_boot_settings
script_name=1.4.3_authentication_required_for_single.sh
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

echo "Setting parameter ExecStart to -/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^ExecStart\s*=" "$CONF_FILE"; then
    sed -i "s|^ExecStart\s*=.*|ExecStart = -/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "ExecStart = -/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0