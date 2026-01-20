#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
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

# Set OPTIONS to run as chrony user (overwrites any existing configuration)
echo 'OPTIONS=-u chrony' > "$CHRONYD_SYSCONFIG"

echo "Configured /etc/sysconfig/chronyd with OPTIONS=-u chrony"

# Restart chronyd to apply changes
systemctl restart chronyd.service

# Verify
echo "Verifying chronyd is running as chrony user:"
ps -ef | grep chronyd | grep -v grep

echo "CIS 2.1.3 remediation complete."
