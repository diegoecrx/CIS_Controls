#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.1.3
# Ensure chrony is not run as the root user
# This script configures chronyd to run as chrony user

set -e

echo "CIS 2.1.3 - Configuring chrony to not run as root..."

CHRONYD_SYSCONFIG="/etc/sysconfig/chronyd"

# Backup existing configuration
if [ -f "$CHRONYD_SYSCONFIG" ]; then
    cp "$CHRONYD_SYSCONFIG" "${CHRONYD_SYSCONFIG}.bak.$(date +%Y%m%d%H%M%S)"
fi

# Check if OPTIONS line exists and configure
if grep -q '^OPTIONS=' "$CHRONYD_SYSCONFIG" 2>/dev/null; then
    # Check if running as root
    if grep -Pq '^\s*OPTIONS="?.*-u\s+root' "$CHRONYD_SYSCONFIG"; then
        echo "chronyd is configured to run as root. Fixing..."
        sed -i 's/^\s*OPTIONS=.*/OPTIONS="-u chrony"/' "$CHRONYD_SYSCONFIG"
    else
        echo "chronyd is not running as root."
    fi
else
    # Add OPTIONS line
    echo 'OPTIONS="-u chrony"' >> "$CHRONYD_SYSCONFIG"
fi

# Restart chronyd to apply changes
systemctl try-reload-or-restart chronyd.service

echo "CIS 2.1.3 remediation complete - chronyd configured to run as chrony user."