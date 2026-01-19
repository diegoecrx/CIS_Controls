#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.2
# Ensure packet redirect sending is disabled
# This script disables packet redirect sending

set -e

echo "CIS 3.3.2 - Disabling packet redirect sending..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Create directory if needed
mkdir -p /etc/sysctl.d

# Remove any existing settings from all sysctl files
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.all\.send_redirects[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.default\.send_redirects[[:space:]]*=/d' "$f" 2>/dev/null || true
    fi
done

# Set redirect sending to disabled
echo "net.ipv4.conf.all.send_redirects = 0" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.default.send_redirects = 0" >> "$SYSCTL_CONF"
echo " - Added send_redirects settings to $SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.2 remediation complete - packet redirect sending disabled."
