#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.1
# Ensure ip forwarding is disabled
# This script disables IP forwarding

set -e

echo "CIS 3.3.1 - Disabling IP forwarding..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"
SYSCTL_CONF6="/etc/sysctl.d/60-netipv6_sysctl.conf"

# Create directory if needed
mkdir -p /etc/sysctl.d

# Remove any existing settings from all sysctl files
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i '/^[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv6\.conf\.all\.forwarding[[:space:]]*=/d' "$f" 2>/dev/null || true
    fi
done

# Set IPv4 forwarding to disabled
echo "net.ipv4.ip_forward = 0" >> "$SYSCTL_CONF"
echo " - Added net.ipv4.ip_forward = 0 to $SYSCTL_CONF"

# Apply the setting
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.route.flush=1

# Check if IPv6 is enabled and disable forwarding
if [ -f /sys/module/ipv6/parameters/disable ] && grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
    echo "net.ipv6.conf.all.forwarding = 0" >> "$SYSCTL_CONF6"
    echo " - Added net.ipv6.conf.all.forwarding = 0 to $SYSCTL_CONF6"
    sysctl -w net.ipv6.conf.all.forwarding=0
    sysctl -w net.ipv6.route.flush=1
fi

echo "CIS 3.3.1 remediation complete - IP forwarding disabled."
