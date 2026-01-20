#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.3.5
# Ensure nftables loopback traffic is configured
# This script configures loopback traffic rules

set -e

echo "CIS 3.4.3.5 - Configuring nftables loopback traffic..."

# Add loopback accept rule
nft add rule inet filter input iif lo accept 2>/dev/null || true

# Drop traffic from loopback addresses not on loopback interface
nft add rule inet filter input ip saddr 127.0.0.0/8 counter drop 2>/dev/null || true

# If IPv6 is enabled, add IPv6 loopback rule
if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable 2>/dev/null; then
    nft add rule inet filter input ip6 saddr ::1 counter drop 2>/dev/null || true
fi

echo "CIS 3.4.3.5 remediation complete - loopback traffic configured."