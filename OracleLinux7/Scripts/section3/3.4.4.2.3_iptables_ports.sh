#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.2.3
# Ensure iptables rules exist for all open ports
# This script checks for open ports and firewall rules

set -e

echo "CIS 3.4.4.2.3 - Checking iptables rules for open ports..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Open ports on this system:"
ss -tuln | grep LISTEN

echo ""
echo "Current iptables INPUT rules:"
iptables -L INPUT -v -n 2>/dev/null || echo "iptables not available"

echo ""
echo "For each open port, ensure a firewall rule exists:"
echo "  iptables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"
echo ""
echo "Example for SSH:"
echo "  iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT"

echo "CIS 3.4.4.2.3 remediation complete - manual review required."