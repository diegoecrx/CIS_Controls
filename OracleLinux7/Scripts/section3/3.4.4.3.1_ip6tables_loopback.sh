#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.1
# Ensure ip6tables loopback traffic is configured
# This script configures ip6tables loopback rules

set -e

echo "CIS 3.4.4.3.1 - Configuring ip6tables loopback traffic..."

# Accept all loopback traffic
ip6tables -A INPUT -i lo -j ACCEPT

# Accept all outbound loopback traffic
ip6tables -A OUTPUT -o lo -j ACCEPT

# Drop all traffic to ::1 that doesn't use lo
ip6tables -A INPUT -s ::1 -j DROP

echo "Verifying ip6tables loopback rules:"
ip6tables -L INPUT -v -n | grep -E "lo|::1"
ip6tables -L OUTPUT -v -n | grep lo

echo "CIS 3.4.4.3.1 remediation complete."