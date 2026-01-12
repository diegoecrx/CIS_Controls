#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.3.3
# Ensure bogus icmp responses are ignored
# This script enables ignoring bogus ICMP responses

set -e

echo "CIS 3.3.3 - Enabling ignore bogus ICMP responses..."

SYSCTL_CONF="/etc/sysctl.d/60-netipv4_sysctl.conf"

# Set to ignore bogus ICMP responses
grep -qE "^\s*net\.ipv4\.icmp_ignore_bogus_error_responses\s*=" /etc/sysctl.conf /etc/sysctl.d/*.conf 2>/dev/null || \
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> "$SYSCTL_CONF"

# Apply the setting
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
sysctl -w net.ipv4.route.flush=1

echo "CIS 3.3.3 remediation complete - bogus ICMP responses ignored."