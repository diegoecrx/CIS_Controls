#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.2.4
# Ensure network interfaces are assigned to appropriate zone
# This script checks network interface zone assignments

set -e

echo "CIS 3.4.2.4 - Checking network interface zone assignments..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Current interface zone assignments:"
for netint in $(find /sys/class/net/* -maxdepth 1 2>/dev/null | awk -F"/" '{print $NF}'); do
    if [ "$netint" != "lo" ]; then
        zone=$(firewall-cmd --get-zone-of-interface="$netint" 2>/dev/null || echo "not assigned")
        echo "  $netint: $zone"
    fi
done

echo ""
echo "To assign an interface to a zone:"
echo "  firewall-cmd --zone=<zone_name> --change-interface=<interface>"
echo ""
echo "Example:"
echo "  firewall-cmd --zone=public --change-interface=eth0"

echo "CIS 3.4.2.4 remediation complete - manual review required."