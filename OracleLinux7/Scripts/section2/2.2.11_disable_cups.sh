#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.11
# Ensure print server services are not in use
# This script stops and masks cups services

set -e

echo "CIS 2.2.11 - Disabling print server services..."

# Stop cups services if running
if systemctl is-active cups.socket &>/dev/null; then
    echo "Stopping cups.socket..."
    systemctl stop cups.socket
fi

if systemctl is-active cups.service &>/dev/null; then
    echo "Stopping cups.service..."
    systemctl stop cups.service
fi

# Mask cups services to prevent them from being started
systemctl mask cups.socket 2>/dev/null || true
systemctl mask cups.service 2>/dev/null || true

echo "CIS 2.2.11 remediation complete - print server services are stopped and masked."