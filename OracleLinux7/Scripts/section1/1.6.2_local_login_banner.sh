#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.6.2 Ensure local login warning banner is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.2 - Configure local login warning banner ==="

# Set warning banner - text configured to match site policy
echo "All activities performed on this system are monitored and recorded. Authorized users only." > /etc/issue
echo " - Configured /etc/issue"

echo " - Local login warning banner configuration complete"