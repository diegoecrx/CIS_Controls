#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.13
# Ensure rsync services are not in use
# This script stops and masks rsyncd services

set -e

echo "CIS 2.2.13 - Disabling rsync services..."

# Stop rsyncd services if running
if systemctl is-active rsyncd.socket &>/dev/null; then
    echo "Stopping rsyncd.socket..."
    systemctl stop rsyncd.socket
fi

if systemctl is-active rsyncd.service &>/dev/null; then
    echo "Stopping rsyncd.service..."
    systemctl stop rsyncd.service
fi

# Mask rsyncd services to prevent them from being started
systemctl mask rsyncd.socket 2>/dev/null || true
systemctl mask rsyncd.service 2>/dev/null || true

echo "CIS 2.2.13 remediation complete - rsync services are stopped and masked."