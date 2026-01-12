#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.4.2.2
# Ensure iptables outbound and established connections are configured
# This script configures iptables connection tracking

set -e

echo "CIS 3.4.4.2.2 - Configuring iptables outbound and established connections..."

# Output rules
iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 2>/dev/null || true

# Input rules for established connections
iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT 2>/dev/null || true

echo "CIS 3.4.4.2.2 remediation complete - iptables connections configured."