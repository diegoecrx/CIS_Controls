#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.3
# Ensure dhcp server services are not in use
# This script stops and masks dhcpd services

set -e

echo "CIS 2.2.3 - Disabling DHCP server services..."

# Stop dhcpd services if running
if systemctl is-active dhcpd.service &>/dev/null; then
    echo "Stopping dhcpd.service..."
    systemctl stop dhcpd.service
fi

if systemctl is-active dhcpd6.service &>/dev/null; then
    echo "Stopping dhcpd6.service..."
    systemctl stop dhcpd6.service
fi

# Mask dhcpd services to prevent them from being started
systemctl mask dhcpd.service 2>/dev/null || true
systemctl mask dhcpd6.service 2>/dev/null || true

echo "CIS 2.2.3 remediation complete - DHCP server services are stopped and masked."