#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.1.1
# Ensure iptables/nftables is installed
# This script installs nftables

set -e

echo "CIS 3.4.1.1 - Installing nftables..."

# Check if nftables is installed
if rpm -q nftables &>/dev/null; then
    echo "nftables is already installed."
else
    echo "Installing nftables..."
    yum install -y nftables
    echo "nftables installed successfully."
fi

echo "CIS 3.4.1.1 remediation complete - nftables installed."