#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.3.1
# Ensure nftables is installed
# This script installs nftables

set -e

echo "CIS 3.4.3.1 - Installing nftables..."

if rpm -q nftables &>/dev/null; then
    echo "nftables is already installed."
else
    echo "Installing nftables..."
    yum install -y nftables
    echo "nftables installed successfully."
fi

echo "CIS 3.4.3.1 remediation complete - nftables installed."