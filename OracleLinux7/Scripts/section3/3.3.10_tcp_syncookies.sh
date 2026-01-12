#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.10
# Ensure tcp syn cookies is enabled
# This script enables TCP SYN cookies

set -e

echo "CIS 3.3.10 - Enabling TCP SYN cookies..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set TCP SYN cookies to enabled
grep -qE "^\s*net\.ipv4\.tcp_syncookies\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.tcp_syncookies = 1" >> "$SYSCTL_CONF"

# Apply the setting
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.10 remediation complete - TCP SYN cookies enabled."