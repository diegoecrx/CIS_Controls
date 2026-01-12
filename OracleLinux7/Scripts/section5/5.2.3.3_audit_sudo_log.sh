#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.3
# Ensure events that modify the sudo log file are collected

set -e

echo "CIS 5.2.3.3 - Configuring sudo log file audit rules..."

# Get sudo log file location
SUDO_LOG_FILE=$(grep -r logfile /etc/sudoers* 2>/dev/null | sed -e 's/.*logfile=//;s/,? .*//' -e 's/"//g' | head -1)

if [ -n "${SUDO_LOG_FILE}" ]; then
    # Create audit rule file
    cat > /etc/audit/rules.d/50-sudo.rules << EOF
-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file
EOF
    echo "Sudo log file found: ${SUDO_LOG_FILE}"
else
    # Default location
    cat > /etc/audit/rules.d/50-sudo.rules << 'EOF'
-w /var/log/sudo.log -p wa -k sudo_log_file
EOF
    echo "Using default sudo log file: /var/log/sudo.log"
fi

# Load rules
augenrules --load

echo "Verifying rules:"
auditctl -l | grep sudo_log_file

# Check if reboot required
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    echo ""
    echo "NOTE: Reboot required to load rules."
fi

echo "CIS 5.2.3.3 remediation complete."