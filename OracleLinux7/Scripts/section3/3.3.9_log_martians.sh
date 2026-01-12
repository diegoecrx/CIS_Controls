#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.9
# Ensure suspicious packets are logged
# This script enables logging of suspicious packets

set -e

echo "CIS 3.3.9 - Enabling logging of suspicious packets..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set to log martians (suspicious packets)
grep -qE "^\s*net\.ipv4\.conf\.all\.log_martians\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.all.log_martians = 1" >> "$SYSCTL_CONF"

grep -qE "^\s*net\.ipv4\.conf\.default\.log_martians\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.default.log_martians = 1" >> "$SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.9 remediation complete - suspicious packets logged."