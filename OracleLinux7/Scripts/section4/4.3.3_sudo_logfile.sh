#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.3.3
# Ensure sudo log file exists
# This script configures sudo logging

set -e

echo "CIS 4.3.3 - Configuring sudo log file..."

# Check if logfile is already configured
if grep -rPsi '^\s*Defaults\s+([^#]+,\s*)?logfile\s*=' /etc/sudoers /etc/sudoers.d/ 2>/dev/null; then
    echo "logfile is already configured."
else
    echo "Adding logfile to sudoers..."
    echo 'Defaults logfile="/var/log/sudo.log"' > /etc/sudoers.d/00_logfile
    chmod 440 /etc/sudoers.d/00_logfile
fi

echo "Verifying configuration:"
grep -ri "logfile" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || true

echo "CIS 4.3.3 remediation complete."