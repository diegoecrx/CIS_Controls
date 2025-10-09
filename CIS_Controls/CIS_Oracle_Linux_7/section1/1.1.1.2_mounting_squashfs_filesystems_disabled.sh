#!/bin/bash
# ID: 1.1.1.2_squashfs.sh 1.1.1.2 Ensure mounting of squashfs filesystems is disabled (Automated)

section=1_initial_setup
sub_section=1.1_filesystem_configuration
script_name=1.1.1.2_squashfs.sh
profile_app_server=2
profile_app_workstation=2

CONF_FILE="/etc/modprobe.d/squashfs.conf"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Ensuring configuration: install squashfs /bin/true in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if [ ! -f "$CONF_FILE" ]; then
    echo "install squashfs /bin/true" > "$CONF_FILE" || result="pending"
    echo "File $CONF_FILE created"
  else
    if ! grep -q "^install squashfs /bin/true$" "$CONF_FILE"; then
      echo "install squashfs /bin/true" >> "$CONF_FILE" || result="pending"
      echo "Appended install squashfs /bin/true to $CONF_FILE"
    fi
  fi
fi

echo "Attempting to remove module squashfs"
rmmod squashfs || true

echo "Executing: rmmod squashfs"
rmmod squashfs || result="pending"


log_event "$result"
exit 0