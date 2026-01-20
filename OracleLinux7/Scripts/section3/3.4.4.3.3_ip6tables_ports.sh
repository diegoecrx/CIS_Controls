#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.3
# Ensure ip6tables firewall rules exist for all open ports
# This script checks for open ports and IPv6 firewall rules

set -e

echo "CIS 3.4.4.3.3 - Checking ip6tables rules for open ports..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Open IPv6 ports on this system:"
ss -tuln6 | grep LISTEN || echo "No IPv6 listening ports found"

echo ""
echo "Current ip6tables INPUT rules:"
ip6tables -L INPUT -v -n 2>/dev/null || echo "ip6tables not available"

echo ""
echo "For each open IPv6 port, ensure a firewall rule exists:"
echo "  ip6tables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"
echo ""
echo "Example for SSH:"
echo "  ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT"

echo "CIS 3.4.4.3.3 remediation complete - manual review required."