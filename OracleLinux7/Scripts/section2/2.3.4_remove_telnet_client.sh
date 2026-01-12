#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.3.4
# Ensure telnet client is not installed
# This script removes telnet package

set -e

echo "CIS 2.3.4 - Removing telnet client..."

# Check if telnet is installed
if rpm -q telnet &>/dev/null; then
    echo "Removing telnet package..."
    yum remove -y telnet
    echo "telnet package removed successfully."
else
    echo "telnet package is not installed."
fi

echo "CIS 2.3.4 remediation complete - telnet client removed."