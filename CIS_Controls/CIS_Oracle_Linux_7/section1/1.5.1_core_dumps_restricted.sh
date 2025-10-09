#!/bin/bash
# ID: 1.5.1_core_dumps_are_restricted.sh 1.5.1 Ensure core dumps are restricted (Automated)

section=1_initial_setup
sub_section=1.5_additional_process_hardening
script_name=1.5.1_core_dumps_are_restricted.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/security/limits.conf"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter fs.suid_dumpable to 0 in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^fs.suid_dumpable\s*=" "$CONF_FILE"; then
    sed -i "s|^fs.suid_dumpable\s*=.*|fs.suid_dumpable = 0|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "fs.suid_dumpable = 0" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Storage to none in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Storage\s*=" "$CONF_FILE"; then
    sed -i "s|^Storage\s*=.*|Storage = none|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Storage = none" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter ProcessSizeMax to 0 in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^ProcessSizeMax\s*=" "$CONF_FILE"; then
    sed -i "s|^ProcessSizeMax\s*=.*|ProcessSizeMax = 0|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "ProcessSizeMax = 0" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Executing: sysctl -w fs.suid_dumpable=0"
sysctl -w fs.suid_dumpable=0 || result="pending"

echo "Executing: systemctl daemon-reload"
systemctl daemon-reload || result="pending"


log_event "$result"
exit 0