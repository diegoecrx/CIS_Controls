#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.5
# Ensure icmp redirects are not accepted
# This script disables ICMP redirect acceptance

set -e

echo "CIS 3.3.5 - Disabling ICMP redirect acceptance..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set to not accept ICMP redirects
grep -qE "^\s*net\.ipv4\.conf\.all\.accept_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.all.accept_redirects = 0" >> "$SYSCTL_CONF"

grep -qE "^\s*net\.ipv4\.conf\.default\.accept_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.conf.default.accept_redirects = 0" >> "$SYSCTL_CONF"

# Apply the settings
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.route.flush=1

# Check if IPv6 is enabled
if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable 2>/dev/null; then
    SYSCTL_CONF6="/etc/sysctl.d/60-netipv6_sysctl.conf"
    grep -qE "^\s*net\.ipv6\.conf\.all\.accept_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
        echo "net.ipv6.conf.all.accept_redirects = 0" >> "$SYSCTL_CONF6"
    grep -qE "^\s*net\.ipv6\.conf\.default\.accept_redirects\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
        echo "net.ipv6.conf.default.accept_redirects = 0" >> "$SYSCTL_CONF6"
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.default.accept_redirects=0
    sysctl -w net.ipv6.route.flush=1
fi

echo "CIS 3.3.5 remediation complete - ICMP redirects not accepted."