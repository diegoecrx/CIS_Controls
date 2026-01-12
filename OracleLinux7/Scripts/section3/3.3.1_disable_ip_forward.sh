#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.1
# Ensure ip forwarding is disabled
# This script disables IP forwarding

set -e

echo "CIS 3.3.1 - Disabling IP forwarding..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set IPv4 forwarding to disabled
if ! grep -qE "^\s*net\.ipv4\.ip_forward\s*=\s*0" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null; then
    echo "net.ipv4.ip_forward = 0" >> "$SYSCTL_CONF"
fi

# Apply the setting
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.route.flush=1

# Check if IPv6 is enabled and disable forwarding
if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable 2>/dev/null; then
    SYSCTL_CONF6="/etc/sysctl.d/60-netipv6_sysctl.conf"
    if ! grep -qE "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*0" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null; then
        echo "net.ipv6.conf.all.forwarding = 0" >> "$SYSCTL_CONF6"
    fi
    sysctl -w net.ipv6.conf.all.forwarding=0
    sysctl -w net.ipv6.route.flush=1
fi

echo "CIS 3.3.1 remediation complete - IP forwarding disabled."