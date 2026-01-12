#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.1
# Ensure autofs services are not in use
# This script stops and masks autofs service

set -e

echo "CIS 2.2.1 - Disabling autofs services..."

# Stop autofs service if running
if systemctl is-active autofs.service &>/dev/null; then
    echo "Stopping autofs.service..."
    systemctl stop autofs.service
fi

# Mask autofs service to prevent it from being started
systemctl mask autofs.service 2>/dev/null || true

echo "CIS 2.2.1 remediation complete - autofs service is stopped and masked."