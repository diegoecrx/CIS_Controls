#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.4
# Ensure inactive password lock is 30 days or less
# This script configures INACTIVE

set -e

echo "CIS 4.5.1.4 - Configuring inactive password lock..."

# Set default inactivity period
useradd -D -f 30

echo "Verifying default configuration:"
useradd -D | grep INACTIVE

echo ""
echo "NOTE: To update existing users, run:"
echo "  chage --inactive 30 <username>"

echo "CIS 4.5.1.4 remediation complete."