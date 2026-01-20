#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.1.1
# Ensure IPv6 status is identified
# This script checks IPv6 status

set -e

echo "CIS 3.1.1 - Checking IPv6 status..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="

if grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
    echo "IPv6 is ENABLED on this system."
else
    echo "IPv6 is DISABLED on this system."
fi

echo ""
echo "Review IPv6 status and configure according to site policy."
echo "If IPv6 is not required, consider disabling it."
echo "If IPv6 is required, ensure proper security configuration."

echo "CIS 3.1.1 remediation complete - manual review required."