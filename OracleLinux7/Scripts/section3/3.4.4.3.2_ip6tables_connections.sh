#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.2
# Ensure ip6tables outbound and established connections are configured
# This script configures ip6tables connection tracking rules

set -e

echo "CIS 3.4.4.3.2 - Configuring ip6tables connection rules..."

# Allow outbound connections
ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow inbound established connections
ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

echo "Verifying ip6tables connection rules:"
ip6tables -L INPUT -v -n | head -15
ip6tables -L OUTPUT -v -n | head -15

echo "CIS 3.4.4.3.2 remediation complete."