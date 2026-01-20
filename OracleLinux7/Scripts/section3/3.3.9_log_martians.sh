#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.3.9
# Ensure suspicious packets are logged

set -e

echo "CIS 3.3.9 - Enabling suspicious packet logging..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

mkdir -p /etc/sysctl.d

for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.all\.log_martians[[:space:]]*=/d' "$f" 2>/dev/null || true
        sed -i '/^[[:space:]]*net\.ipv4\.conf\.default\.log_martians[[:space:]]*=/d' "$f" 2>/dev/null || true
    fi
done

echo "net.ipv4.conf.all.log_martians = 1" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.default.log_martians = 1" >> "$SYSCTL_CONF"
echo " - Added log_martians settings to $SYSCTL_CONF"

sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.9 remediation complete."
