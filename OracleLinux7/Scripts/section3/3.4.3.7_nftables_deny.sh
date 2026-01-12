#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.3.7
# Ensure nftables default deny firewall policy
# This script sets default drop policies with user confirmation

set -e

echo "CIS 3.4.3.7 - Configure nftables default deny policy..."
echo ""
echo "=============================================="
echo "WARNING: THIS WILL SET DEFAULT DROP POLICY"
echo "This can lock you out of SSH if rules are not configured!"
echo "=============================================="
echo ""

# Show current rules
echo "Current nftables rules:"
nft list ruleset 2>/dev/null || echo "No rules found"
echo ""

# Prompt for confirmation
read -p "Are you sure you want to set default DROP policies? (yes/no): " RESPONSE

if [[ ! "$RESPONSE" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Aborted. No changes made."
    exit 0
fi

echo ""
echo "Applying default deny policies..."

# Check if table exists
if ! nft list table inet filter 2>/dev/null; then
    echo "Creating filter table first..."
    nft create table inet filter
fi

# Set base chain policies to drop
nft chain inet filter input '{ policy drop ; }' 2>/dev/null || \
    nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'

nft chain inet filter forward '{ policy drop ; }' 2>/dev/null || \
    nft add chain inet filter forward '{ type filter hook forward priority 0 ; policy drop ; }'

nft chain inet filter output '{ policy drop ; }' 2>/dev/null || \
    nft add chain inet filter output '{ type filter hook output priority 0 ; policy drop ; }'

echo ""
echo "Default deny policies applied. Current ruleset:"
nft list ruleset

echo ""
echo "CIS 3.4.3.7 remediation complete."