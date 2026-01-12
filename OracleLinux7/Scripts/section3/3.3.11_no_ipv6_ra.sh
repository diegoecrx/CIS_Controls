#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.11
# Ensure ipv6 router advertisements are not accepted
# This script disables IPv6 router advertisements

set -e

echo "CIS 3.3.11 - Disabling IPv6 router advertisements..."

# Check if IPv6 is enabled
if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable 2>/dev/null; then
    SYSCTL_CONF="/etc/sysctl.d/60-netipv6_sysctl.conf"
    
    # Set to not accept IPv6 router advertisements
    grep -qE "^\s*net\.ipv6\.conf\.all\.accept_ra\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
        echo "net.ipv6.conf.all.accept_ra = 0" >> "$SYSCTL_CONF"
    
    grep -qE "^\s*net\.ipv6\.conf\.default\.accept_ra\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
        echo "net.ipv6.conf.default.accept_ra = 0" >> "$SYSCTL_CONF"
    
    # Apply the settings
    sysctl -w net.ipv6.conf.all.accept_ra=0
    sysctl -w net.ipv6.conf.default.accept_ra=0
    sysctl -w net.ipv6.route.flush=1
    
    echo "IPv6 router advertisements disabled."
else
    echo "IPv6 is not enabled on this system. No action needed."
fi

echo "CIS 3.3.11 remediation complete."