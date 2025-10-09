#!/bin/bash
# ID: 1.1.10_separate_exists_for_var.sh 1.1.2 Ensure /tmp is configured (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.10_separate_exists_for_var.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/fstab"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter What to tmpfs in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^What\s*=" "$CONF_FILE"; then
    sed -i "s|^What\s*=.*|What = tmpfs|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "What = tmpfs" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Where to /tmp in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Where\s*=" "$CONF_FILE"; then
    sed -i "s|^Where\s*=.*|Where = /tmp|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Where = /tmp" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Type to tmpfs in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Type\s*=" "$CONF_FILE"; then
    sed -i "s|^Type\s*=.*|Type = tmpfs|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Type = tmpfs" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Options to mode=1777,strictatime,noexec,nodev,nosuid in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Options\s*=" "$CONF_FILE"; then
    sed -i "s|^Options\s*=.*|Options = mode=1777,strictatime,noexec,nodev,nosuid|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Options = mode=1777,strictatime,noexec,nodev,nosuid" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Executing: mount -o remount,noexec,nodev,nosuid /tmp"
mount -o remount,noexec,nodev,nosuid /tmp || result="pending"

echo "Executing: systemctl daemon-reload"
systemctl daemon-reload || result="pending"

echo "Executing: systemctl --now unmask tmp.mount"
systemctl --now unmask tmp.mount || result="pending"


log_event "$result"
exit 0