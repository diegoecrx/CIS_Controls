#!/bin/bash
# CIS Oracle Linux 7 - 1.6.2 Ensure local login warning banner is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.2 - Configure local login warning banner ==="

# Set warning banner
echo "Authorized users only. All activity may be monitored and reported." > /etc/issue
echo " - Configured /etc/issue"

echo " - Local login warning banner configuration complete"
