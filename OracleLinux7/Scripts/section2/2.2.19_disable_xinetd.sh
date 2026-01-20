#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.19
# Ensure xinetd services are not in use
# This script stops and masks xinetd service

set -e

echo "CIS 2.2.19 - Disabling xinetd services..."

# Stop xinetd service if running
if systemctl is-active xinetd.service &>/dev/null; then
    echo "Stopping xinetd.service..."
    systemctl stop xinetd.service
fi

# Mask xinetd service to prevent it from being started
systemctl mask xinetd.service 2>/dev/null || true

echo "CIS 2.2.19 remediation complete - xinetd service is stopped and masked."