#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.1.3
# Ensure bluetooth services are not in use
# This script stops and masks bluetooth service

set -e

echo "CIS 3.1.3 - Disabling bluetooth services..."

# Stop bluetooth service if running
if systemctl is-active bluetooth.service &>/dev/null; then
    echo "Stopping bluetooth.service..."
    systemctl stop bluetooth.service
fi

# Mask bluetooth service to prevent it from being started
systemctl mask bluetooth.service 2>/dev/null || true

echo "CIS 3.1.3 remediation complete - bluetooth service is stopped and masked."