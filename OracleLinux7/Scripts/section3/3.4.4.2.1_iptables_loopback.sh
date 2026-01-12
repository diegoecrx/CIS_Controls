#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.4.2.1
# Ensure iptables loopback traffic is configured
# This script configures iptables loopback rules

set -e

echo "CIS 3.4.4.2.1 - Configuring iptables loopback traffic..."

# Accept traffic on loopback interface
iptables -A INPUT -i lo -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o lo -j ACCEPT 2>/dev/null || true

# Drop traffic from loopback addresses not on loopback interface
iptables -A INPUT -s 127.0.0.0/8 -j DROP 2>/dev/null || true

echo "CIS 3.4.4.2.1 remediation complete - iptables loopback configured."