#!/bin/bash
# ID: 1.8.2_gdm_login_banner.sh 1.8.2 Ensure GDM login banner is configured (Automated)

section=1_initial_setup
sub_section=1.8_gnome_display_manager
script_name=1.8.2_gdm_login_banner.sh
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

echo "Setting parameter banner-message-enable to true in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^banner-message-enable\s*=" "$CONF_FILE"; then
    sed -i "s|^banner-message-enable\s*=.*|banner-message-enable = true|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "banner-message-enable = true" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter banner-message-text to '<banner message>' in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^banner-message-text\s*=" "$CONF_FILE"; then
    sed -i "s|^banner-message-text\s*=.*|banner-message-text = '<banner message>'|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "banner-message-text = '<banner message>'" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi


log_event "$result"
exit 0