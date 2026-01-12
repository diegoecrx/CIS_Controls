#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.6
# Ensure secure icmp redirects are not accepted
# This script disables secure ICMP redirect acceptance

set -e

echo "CIS 3.3.6 - Disabling secure ICMP redirect acceptance..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set to not accept secure ICMP redirects
grep -qE "^\s*net\.ipv4\.conf\.all\.secure_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.all.secure_redirects = 0" >> "$SYSCTL_CONF"

grep -qE "^\s*net\.ipv4\.conf\.default\.secure_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.default.secure_redirects = 0" >> "$SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.6 remediation complete - secure ICMP redirects not accepted."