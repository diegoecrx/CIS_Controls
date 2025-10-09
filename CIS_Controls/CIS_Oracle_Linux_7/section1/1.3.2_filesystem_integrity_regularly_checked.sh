#!/bin/bash
# ID: 1.3.2_filesystem_integrity_regularly_checked.sh 1.3.2 Ensure filesystem integrity is regularly checked (Automated)

section=1_initial_setup
sub_section=1.3_filesystem_integrity_checking
script_name=1.3.2_filesystem_integrity_regularly_checked.sh
profile_app_server=1
profile_app_workstation=1

CONF_FILE="/etc/systemd/system/aidecheck.service"
LOG_FILE="cis_event.log"

log_event() {
  local result="$1"
  local timestamp=$(date +"%d/%m/%Y %H:%M")
  echo "$timestamp $CONF_FILE $sub_section $script_name $result" >> "$LOG_FILE"
}

# Remediation commands
result="success"

echo "Setting parameter Description to Aide Check in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Description\s*=" "$CONF_FILE"; then
    sed -i "s|^Description\s*=.*|Description = Aide Check|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Description = Aide Check" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Type to simple in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Type\s*=" "$CONF_FILE"; then
    sed -i "s|^Type\s*=.*|Type = simple|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Type = simple" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter ExecStart to /usr/sbin/aide --check in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^ExecStart\s*=" "$CONF_FILE"; then
    sed -i "s|^ExecStart\s*=.*|ExecStart = /usr/sbin/aide --check|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "ExecStart = /usr/sbin/aide --check" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter WantedBy to multi-user.target in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^WantedBy\s*=" "$CONF_FILE"; then
    sed -i "s|^WantedBy\s*=.*|WantedBy = multi-user.target|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "WantedBy = multi-user.target" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Description to Aide check every day at 5AM in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Description\s*=" "$CONF_FILE"; then
    sed -i "s|^Description\s*=.*|Description = Aide check every day at 5AM|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Description = Aide check every day at 5AM" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter OnCalendar to *-*-* 05:00:00 in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^OnCalendar\s*=" "$CONF_FILE"; then
    sed -i "s|^OnCalendar\s*=.*|OnCalendar = *-*-* 05:00:00|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "OnCalendar = *-*-* 05:00:00" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter Unit to aidecheck.service in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^Unit\s*=" "$CONF_FILE"; then
    sed -i "s|^Unit\s*=.*|Unit = aidecheck.service|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "Unit = aidecheck.service" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Setting parameter WantedBy to multi-user.target in $CONF_FILE"
if [ -n "$CONF_FILE" ]; then
  if grep -q "^WantedBy\s*=" "$CONF_FILE"; then
    sed -i "s|^WantedBy\s*=.*|WantedBy = multi-user.target|" "$CONF_FILE" || result="pending"
    echo "Updated existing parameter"
  else
    echo "WantedBy = multi-user.target" >> "$CONF_FILE" || result="pending"
    echo "Added new parameter"
  fi
fi

echo "Executing: crontab -u root -e"
crontab -u root -e || result="pending"

echo "Executing: chown root:root /etc/systemd/system/aidecheck.*"
chown root:root /etc/systemd/system/aidecheck.* || result="pending"

echo "Executing: chmod 0644 /etc/systemd/system/aidecheck.*"
chmod 0644 /etc/systemd/system/aidecheck.* || result="pending"

echo "Executing: systemctl daemon-reload"
systemctl daemon-reload || result="pending"

echo "Executing: systemctl enable aidecheck.service"
systemctl enable aidecheck.service || result="pending"

echo "Executing: systemctl --now enable aidecheck.timer"
systemctl --now enable aidecheck.timer || result="pending"


log_event "$result"
exit 0