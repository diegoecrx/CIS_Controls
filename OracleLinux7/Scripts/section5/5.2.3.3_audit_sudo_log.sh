#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.3
# Ensure events that modify the sudo log file are collected

set -e

echo "CIS 5.2.3.3 - Configuring sudo log file audit rules..."

# Default sudo log file location
DEFAULT_SUDO_LOG="/var/log/sudo.log"

# Get sudo log file location from sudoers
SUDO_LOG_FILE=$(grep -r logfile /etc/sudoers* 2>/dev/null | sed -e 's/.*logfile=//;s/,? .*//' -e 's/"//g' | head -1)

# If no logfile is configured in sudoers, configure one
if [ -z "${SUDO_LOG_FILE}" ]; then
    echo "No sudo logfile configured in /etc/sudoers."
    echo "Configuring sudo to log to ${DEFAULT_SUDO_LOG}..."
    
    # Add logfile configuration to sudoers.d
    cat > /etc/sudoers.d/99-sudo-logfile << EOF
# CIS 5.2.3.3 - Configure sudo logging
Defaults logfile="${DEFAULT_SUDO_LOG}"
EOF
    chmod 440 /etc/sudoers.d/99-sudo-logfile
    
    SUDO_LOG_FILE="${DEFAULT_SUDO_LOG}"
    echo " - Created /etc/sudoers.d/99-sudo-logfile"
    
    # Create the log file if it doesn't exist
    touch "${SUDO_LOG_FILE}"
    chmod 600 "${SUDO_LOG_FILE}"
    echo " - Created ${SUDO_LOG_FILE}"
fi

echo "Sudo log file: ${SUDO_LOG_FILE}"

# Create audit rule file
cat > /etc/audit/rules.d/50-sudo.rules << EOF
# CIS 5.2.3.3 - Audit sudo log file modifications
-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file
EOF

echo " - Created /etc/audit/rules.d/50-sudo.rules"

# Load rules
echo "Loading audit rules..."
augenrules --load 2>/dev/null || true

echo "Verifying rules:"
auditctl -l 2>/dev/null | grep sudo_log_file || echo "Rules will be active after reboot"

# Check if reboot required
if [[ $(auditctl -s 2>/dev/null | grep "enabled") =~ "2" ]]; then
    echo ""
    echo "NOTE: Reboot required to load rules (audit in immutable mode)."
fi

echo ""
echo "CIS 5.2.3.3 remediation complete."
