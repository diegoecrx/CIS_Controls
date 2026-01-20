#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.2.3
# Ensure firewalld drops unnecessary services and ports
# This script checks firewalld configuration

set -e

echo "CIS 3.4.2.3 - Checking firewalld services and ports..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

# Get active zone
ACTIVE_ZONE=$(firewall-cmd --get-active-zones 2>/dev/null | head -1 || echo "none")
echo "Active Zone: $ACTIVE_ZONE"
echo ""

if [ "$ACTIVE_ZONE" != "none" ]; then
    echo "Current services and ports:"
    firewall-cmd --list-all --zone="$ACTIVE_ZONE" 2>/dev/null | grep -P -- '^\h*(services:|ports:)' || true
    echo ""
    echo "To remove an unnecessary service:"
    echo "  firewall-cmd --remove-service=<service_name>"
    echo ""
    echo "To remove an unnecessary port:"
    echo "  firewall-cmd --remove-port=<port>/<protocol>"
    echo ""
    echo "To make changes persistent:"
    echo "  firewall-cmd --runtime-to-permanent"
else
    echo "FirewallD is not running or no active zone."
fi

echo "CIS 3.4.2.3 remediation complete - manual review required."