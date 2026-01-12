#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.16
# Ensure tftp server services are not in use
# This script stops and masks tftp services

set -e

echo "CIS 2.2.16 - Disabling TFTP server services..."

# Stop tftp services if running
if systemctl is-active tftp.socket &>/dev/null; then
    echo "Stopping tftp.socket..."
    systemctl stop tftp.socket
fi

if systemctl is-active tftp.service &>/dev/null; then
    echo "Stopping tftp.service..."
    systemctl stop tftp.service
fi

# Mask tftp services to prevent them from being started
systemctl mask tftp.socket 2>/dev/null || true
systemctl mask tftp.service 2>/dev/null || true

echo "CIS 2.2.16 remediation complete - TFTP server services are stopped and masked."