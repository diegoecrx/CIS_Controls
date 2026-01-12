#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.2
# Ensure packet redirect sending is disabled
# This script disables packet redirect sending

set -e

echo "CIS 3.3.2 - Disabling packet redirect sending..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set redirect sending to disabled
grep -qE "^\s*net\.ipv4\.conf\.all\.send_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.all.send_redirects = 0" >> "$SYSCTL_CONF"

grep -qE "^\s*net\.ipv4\.conf\.default\.send_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.default.send_redirects = 0" >> "$SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.2 remediation complete - packet redirect sending disabled."