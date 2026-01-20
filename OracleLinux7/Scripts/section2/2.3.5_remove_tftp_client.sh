#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.3.5
# Ensure tftp client is not installed
# This script removes tftp package

set -e

echo "CIS 2.3.5 - Removing TFTP client..."

# Check if tftp is installed
if rpm -q tftp &>/dev/null; then
    echo "Removing tftp package..."
    yum remove -y tftp
    echo "tftp package removed successfully."
else
    echo "tftp package is not installed."
fi

echo "CIS 2.3.5 remediation complete - TFTP client removed."