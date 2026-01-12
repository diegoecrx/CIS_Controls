#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.3.3
# Ensure nis client is not installed
# This script removes ypbind package

set -e

echo "CIS 2.3.3 - Removing NIS client..."

# Check if ypbind is installed
if rpm -q ypbind &>/dev/null; then
    echo "Removing ypbind package..."
    yum remove -y ypbind
    echo "ypbind package removed successfully."
else
    echo "ypbind package is not installed."
fi

echo "CIS 2.3.3 remediation complete - NIS client removed."