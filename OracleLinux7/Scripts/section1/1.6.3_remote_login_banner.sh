#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.6.3 Ensure remote login warning banner is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.3 - Configure remote login warning banner ==="

# Set warning banner for remote logins - text configured to match site policy
echo "All activities performed on this system are monitored and recorded. Authorized users only." > /etc/issue.net
echo " - Configured /etc/issue.net"

echo " - Remote login warning banner configuration complete"