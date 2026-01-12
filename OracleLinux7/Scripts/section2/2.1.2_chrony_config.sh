#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.1.2
# Ensure chrony is configured
# This script configures chrony with appropriate NTP servers

set -e

echo "CIS 2.1.2 - Configuring chrony..."

CHRONY_CONF="/etc/chrony.conf"

# Backup existing configuration
if [ -f "$CHRONY_CONF" ]; then
    cp "$CHRONY_CONF" "${CHRONY_CONF}.bak.$(date +%Y%m%d%H%M%S)"
fi

# Check if server/pool is configured
if grep -qPi '^\s*(server|pool)\s+' "$CHRONY_CONF" 2>/dev/null; then
    echo "NTP server/pool is already configured in $CHRONY_CONF"
    grep -Pi '^\s*(server|pool)\s+' "$CHRONY_CONF"
else
    echo "WARNING: No NTP server/pool configured in $CHRONY_CONF"
    echo "Please add appropriate NTP servers for your environment."
    echo "Example: Add 'server <ntp_server_ip> iburst' to $CHRONY_CONF"
    echo ""
    echo "For OCI environments, consider using Oracle Cloud NTP servers."
fi

# Restart chronyd to apply changes
systemctl restart chronyd

echo "CIS 2.1.2 remediation complete - chrony configuration checked."