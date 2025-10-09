#!/bin/bash
# ID: 1.5.3_address_space_layout_randomization.sh 1.5.3 Ensure address space layout randomization (ASLR) is enabled (Automated)

section=1_initial_setup
sub_section=1.5_additional_process_hardening
script_name=1.5.3_address_space_layout_randomization.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/sysctl.conf"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter kernel.randomize_va_space to 2 in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^kernel.randomize_va_space\s*=" "$CONF_FILE"; then
    sed -i "s|^kernel.randomize_va_space\s*=.*|kernel.randomize_va_space = 2|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "kernel.randomize_va_space = 2" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Executing: sysctl -w kernel.randomize_va_space=2"
sysctl -w kernel.randomize_va_space=2 || result="pending"


log_event "$result"
exit 0