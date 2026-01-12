#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.3.4
# Ensure nftables base chains exist
# This script creates nftables base chains

set -e

echo "CIS 3.4.3.4 - Creating nftables base chains..."
echo "=============================================="
echo "WARNING: Creating chains with drop policy while"
echo "connected over SSH can lock you out."
echo "=============================================="

# Create input chain if it doesn't exist
if ! nft list chain inet filter input &>/dev/null; then
    nft create chain inet filter input { type filter hook input priority 0 \; }
    echo "Input chain created."
fi

# Create forward chain if it doesn't exist
if ! nft list chain inet filter forward &>/dev/null; then
    nft create chain inet filter forward { type filter hook forward priority 0 \; }
    echo "Forward chain created."
fi

# Create output chain if it doesn't exist
if ! nft list chain inet filter output &>/dev/null; then
    nft create chain inet filter output { type filter hook output priority 0 \; }
    echo "Output chain created."
fi

echo "CIS 3.4.3.4 remediation complete - nftables base chains exist."