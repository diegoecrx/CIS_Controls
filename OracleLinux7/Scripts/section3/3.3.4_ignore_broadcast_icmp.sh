#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.4
# Ensure broadcast icmp requests are ignored
# This script enables ignoring broadcast ICMP requests

set -e

echo "CIS 3.3.4 - Enabling ignore broadcast ICMP requests..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set to ignore broadcast ICMP requests
grep -qE "^\s*net\.ipv4\.icmp_echo_ignore_broadcasts\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> "$SYSCTL_CONF"

# Apply the setting
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.4 remediation complete - broadcast ICMP requests ignored."