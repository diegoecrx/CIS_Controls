#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.5
# Ensure dnsmasq services are not in use
# This script stops and masks dnsmasq service

set -e

echo "CIS 2.2.5 - Disabling dnsmasq services..."

# Stop dnsmasq service if running
if systemctl is-active dnsmasq.service &>/dev/null; then
    echo "Stopping dnsmasq.service..."
    systemctl stop dnsmasq.service
fi

# Mask dnsmasq service to prevent it from being started
systemctl mask dnsmasq.service 2>/dev/null || true

echo "CIS 2.2.5 remediation complete - dnsmasq service is stopped and masked."