#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.7
# Ensure reverse path filtering is enabled
# This script enables reverse path filtering

set -e

echo "CIS 3.3.7 - Enabling reverse path filtering..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set reverse path filtering to enabled
grep -qE "^\s*net\.ipv4\.conf\.all\.rp_filter\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.all.rp_filter = 1" >> "$SYSCTL_CONF"

grep -qE "^\s*net\.ipv4\.conf\.default\.rp_filter\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.default.rp_filter = 1" >> "$SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.7 remediation complete - reverse path filtering enabled."