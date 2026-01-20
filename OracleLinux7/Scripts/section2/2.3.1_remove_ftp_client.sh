#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.3.1
# Ensure ftp client is not installed
# This script removes ftp package

set -e

echo "CIS 2.3.1 - Removing FTP client..."

# Check if ftp is installed
if rpm -q ftp &>/dev/null; then
    echo "Removing ftp package..."
    yum remove -y ftp
    echo "ftp package removed successfully."
else
    echo "ftp package is not installed."
fi

echo "CIS 2.3.1 remediation complete - FTP client removed."