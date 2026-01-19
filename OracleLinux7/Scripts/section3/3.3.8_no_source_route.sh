#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.8
# Ensure source routed packets are not accepted

set -e

echo "CIS 3.3.8 - Disabling source routed packet acceptance..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"
SYSCTL_CONF6="/etc/sysctl.d/60-netipv6_sysctl.conf"

mkdir -p /etc/sysctl.d

for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.all\.accept_source_route[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.default\.accept_source_route[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv6\.conf\.all\.accept_source_route[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv6\.conf\.default\.accept_source_route[[:space:]]*=/d' "$f" 2>/dev/null || true
    fi
done

echo "net.ipv4.conf.all.accept_source_route = 0" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.default.accept_source_route = 0" >> "$SYSCTL_CONF"
echo " - Added IPv4 accept_source_route settings to $SYSCTL_CONF"

sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.route.flush=1

if [ -f /sys/module/ipv6/parameters/disable ] && grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
    echo "net.ipv6.conf.all.accept_source_route = 0" >> "$SYSCTL_CONF6"
    echo "net.ipv6.conf.default.accept_source_route = 0" >> "$SYSCTL_CONF6"
    echo " - Added IPv6 accept_source_route settings to $SYSCTL_CONF6"
    sysctl -w net.ipv6.conf.all.accept_source_route=0
    sysctl -w net.ipv6.conf.default.accept_source_route=0
    sysctl -w net.ipv6.route.flush=1
fi

echo "CIS 3.3.8 remediation complete."
