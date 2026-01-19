#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.11
# Ensure IPv6 router advertisements are not accepted

set -e

echo "CIS 3.3.11 - Disabling IPv6 router advertisements..."

SYSCTL_CONF6="/etc/sysctl.d/60-netipv6_sysctl.conf"

mkdir -p /etc/sysctl.d

# Check if IPv6 is enabled
if [ -f /sys/module/ipv6/parameters/disable ] && grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
    for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
        if [ -f "$f" ]; then
            sed -i '/^[[:space:]]*net\.ipv6\.conf\.all\.accept_ra[[:space:]]*=/d' "$f" 2>/dev/null || true
            sed -i '/^[[:space:]]*net\.ipv6\.conf\.default\.accept_ra[[:space:]]*=/d' "$f" 2>/dev/null || true
        fi
    done

    echo "net.ipv6.conf.all.accept_ra = 0" >> "$SYSCTL_CONF6"
    echo "net.ipv6.conf.default.accept_ra = 0" >> "$SYSCTL_CONF6"
    echo " - Added IPv6 accept_ra settings to $SYSCTL_CONF6"

    sysctl -w net.ipv6.conf.all.accept_ra=0
    sysctl -w net.ipv6.conf.default.accept_ra=0
    sysctl -w net.ipv6.route.flush=1
else
    echo " - IPv6 is disabled, skipping router advertisement configuration"
fi

echo "CIS 3.3.11 remediation complete."
