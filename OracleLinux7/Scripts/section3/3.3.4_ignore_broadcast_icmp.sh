#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.3.4
# Ensure broadcast ICMP requests are ignored

set -e

echo "CIS 3.3.4 - Configuring broadcast ICMP request handling..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"
PARAM="net.ipv4.icmp_echo_ignore_broadcasts"
VALUE="1"

mkdir -p /etc/sysctl.d

for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i "/^[[:space:]]*${PARAM}[[:space:]]*=/d" "$f" 2>/dev/null || true
    fi
done

echo "$PARAM = $VALUE" >> "$SYSCTL_CONF"
echo " - Added $PARAM = $VALUE to $SYSCTL_CONF"

sysctl -w ${PARAM}=${VALUE}
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.4 remediation complete."
