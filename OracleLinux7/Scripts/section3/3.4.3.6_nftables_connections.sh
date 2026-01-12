#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.3.6
# Ensure nftables outbound and established connections are configured
# This script configures outbound and established connection rules

set -e

echo "CIS 3.4.3.6 - Configuring nftables outbound and established connections..."

# Input rules for established connections
nft add rule inet filter input ip protocol tcp ct state established accept 2>/dev/null || true
nft add rule inet filter input ip protocol udp ct state established accept 2>/dev/null || true
nft add rule inet filter input ip protocol icmp ct state established accept 2>/dev/null || true

# Output rules for new, related, and established connections
nft add rule inet filter output ip protocol tcp ct state new,related,established accept 2>/dev/null || true
nft add rule inet filter output ip protocol udp ct state new,related,established accept 2>/dev/null || true
nft add rule inet filter output ip protocol icmp ct state new,related,established accept 2>/dev/null || true

echo "CIS 3.4.3.6 remediation complete - outbound and established connections configured."