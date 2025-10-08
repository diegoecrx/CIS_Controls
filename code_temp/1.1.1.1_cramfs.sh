#!/bin/bash
# ID: 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Automated)

section=1_initial_setup
sub-section=1.1_filesystem_configuration

PROFILE_APP_SERVER="Level1"
PROFILE_APP_WORKSTATION="Level1"

CONF_FILE="/etc/modprobe.d/cramfs.conf"
LOG_FILE="/CIS_Oracle_Linux_7/section1/section1.log"


if [ ! -f "$CONF_FILE" ]; then
    echo "Configuration file $CONF_FILE not found. Creating..."
    echo "install cramfs /bin/true" > "$CONF_FILE"
else
    echo "Configuration file $CONF_FILE found. Editing..."
    echo "install cramfs /bin/true" >> "$CONF_FILE"
fi

# Remove the cramfs module if it is loaded
echo "Removing cramfs module if loaded..."
rmmod cramfs
if [ $? -eq 0 ]; then
    echo "Cramfs module removed successfully."
else
    echo "Cramfs module was not loaded or could not be removed."
fi

# Execute remediation commands
rmmod cramfs

echo "Remediation executed."
exit 0


# Define compliance
if [[ "$is_loaded" == "false" && "$is_disabled" == "true" ]]; then
    compliance=true
else
    compliance=false
fi

# Gera timestamp (ex: 2:56 PM 10/8/2025)
timestamp="$(date +'%-I:%M %p %-m/%-d/%Y')"

# Linha de log
log_line="$timestamp 1.1_filesystem_configuration  1.1.1.1_cramfs.sh compliance=$compliance"

# Escreve log
echo "$log_line" >> "$LOG_FILE"a
