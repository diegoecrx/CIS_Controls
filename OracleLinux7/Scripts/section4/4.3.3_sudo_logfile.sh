#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.3.3
# Ensure sudo log file exists
# This script configures sudo logging

set -e

echo "CIS 4.3.3 - Configuring sudo log file..."

# Check if logfile is already configured
if grep -rPsi '^\s*Defaults\s+([^#]+,\s*)?logfile\s*=' /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "logfile is already configured."
    grep -ri "logfile" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || true
else
    echo "Adding logfile to sudoers..."
    # Use format without quotes to avoid parsing issues
    echo 'Defaults logfile=/var/log/sudo.log' > /etc/sudoers.d/00_logfile
    chmod 440 /etc/sudoers.d/00_logfile
    
    # Validate sudoers syntax
    if visudo -c; then
        echo "Sudo configuration is valid."
    else
        echo "ERROR: Invalid sudoers configuration!"
        rm -f /etc/sudoers.d/00_logfile
        exit 1
    fi
fi

echo "Verifying configuration:"
grep -ri "logfile" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || true

echo "CIS 4.3.3 remediation complete."
