#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.3.3
# Ensure an nftables table exists
# This script creates a nftables table

set -e

echo "CIS 3.4.3.3 - Creating nftables table..."

# Check if table exists
if nft list tables 2>/dev/null | grep -q "inet filter"; then
    echo "nftables inet filter table already exists."
else
    echo "Creating nftables inet filter table..."
    nft create table inet filter
    echo "Table created successfully."
fi

echo "CIS 3.4.3.3 remediation complete - nftables table exists."