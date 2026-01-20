#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.3.3
# Ensure bogus ICMP responses are ignored

set -e

echo "CIS 3.3.3 - Configuring bogus ICMP response handling..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"
PARAM="net.ipv4.icmp_ignore_bogus_error_responses"
VALUE="1"

# Create directory if needed
mkdir -p /etc/sysctl.d

# Remove any existing settings from all sysctl files
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i "/^[[:space:]]*${PARAM}[[:space:]]*=/d" "$f" 2>/dev/null || true
    fi
done

# Add the setting
echo "$PARAM = $VALUE" >> "$SYSCTL_CONF"
echo " - Added $PARAM = $VALUE to $SYSCTL_CONF"

# Apply the settings
sysctl -w ${PARAM}=${VALUE}
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.3 remediation complete."
