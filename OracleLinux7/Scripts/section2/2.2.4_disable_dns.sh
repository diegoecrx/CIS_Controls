#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.4
# Ensure dns server services are not in use
# This script stops and masks named service

set -e

echo "CIS 2.2.4 - Disabling DNS server services..."

# Stop named service if running
if systemctl is-active named.service &>/dev/null; then
    echo "Stopping named.service..."
    systemctl stop named.service
fi

# Mask named service to prevent it from being started
systemctl mask named.service 2>/dev/null || true

echo "CIS 2.2.4 remediation complete - DNS server service is stopped and masked."