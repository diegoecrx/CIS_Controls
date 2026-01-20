#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.4
# Ensure ip6tables default deny firewall policy
# This script sets default DROP policies with user confirmation

set -e

echo "CIS 3.4.4.3.4 - Configure ip6tables default deny policy..."
echo ""
echo "=============================================="
echo "WARNING: THIS WILL SET DEFAULT DROP POLICY"
echo "This can lock you out of SSH if rules are not configured!"
echo "=============================================="
echo ""

# Show current rules
echo "Current ip6tables INPUT rules:"
ip6tables -L INPUT -v -n 2>/dev/null || echo "ip6tables not available"
echo ""

# Check for SSH rule
if ip6tables -L INPUT -n 2>/dev/null | grep -q "dpt:22"; then
    echo "[OK] SSH rule (port 22) detected."
else
    echo "[WARNING] No SSH rule detected on port 22!"
fi
echo ""

# Prompt for confirmation
read -p "Are you sure you want to set default DROP policies? (yes/no): " RESPONSE

if [[ ! "$RESPONSE" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Aborted. No changes made."
    exit 0
fi

echo ""

# Add SSH rule if not present
if ! ip6tables -L INPUT -n | grep -q "dpt:22"; then
    echo "Adding SSH allow rule first for safety..."
    ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
fi

# Set default policies to DROP
echo "Setting default DROP policies..."
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

echo ""
echo "Default deny policies applied:"
ip6tables -L -v -n | head -15

echo ""
echo "CIS 3.4.4.3.4 remediation complete."