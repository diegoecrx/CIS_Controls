#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.6
# Ensure secure ICMP redirects are not accepted

set -e

echo "CIS 3.3.6 - Disabling secure ICMP redirect acceptance..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

mkdir -p /etc/sysctl.d

for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.all\.secure_redirects[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.default\.secure_redirects[[:space:]]*=/d' "$f" 2>/dev/null || true
    fi
done

echo "net.ipv4.conf.all.secure_redirects = 0" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.default.secure_redirects = 0" >> "$SYSCTL_CONF"
echo " - Added secure_redirects settings to $SYSCTL_CONF"

sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.6 remediation complete."
