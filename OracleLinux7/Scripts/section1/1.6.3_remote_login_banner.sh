#!/bin/bash
# CIS Oracle Linux 7 - 1.6.3 Ensure remote login warning banner is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.3 - Configure remote login warning banner ==="

# Set warning banner for remote logins
echo "Authorized users only. All activity may be monitored and reported." > /etc/issue.net
echo " - Configured /etc/issue.net"

echo " - Remote login warning banner configuration complete"
