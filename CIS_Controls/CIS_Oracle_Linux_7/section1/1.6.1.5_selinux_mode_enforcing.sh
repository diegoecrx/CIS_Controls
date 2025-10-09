#!/bin/bash
# ID: 1.6.1.5_selinux_mode_enforcing.sh 1.6.1.5 Ensure the SELinux mode is enforcing (Automated)

section=1_initial_setup
sub_section=1.6_mandatory_access_control
script_name=1.6.1.5_selinux_mode_enforcing.sh
profile_app_server=2
profile_app_workstation=2

CONF_FILE="/etc/selinux/config"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter SELINUX to enforcing in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^SELINUX\s*=" "$CONF_FILE"; then
    sed -i "s|^SELINUX\s*=.*|SELINUX = enforcing|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "SELINUX = enforcing" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0