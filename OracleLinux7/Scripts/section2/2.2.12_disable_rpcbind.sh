#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.12
# Ensure rpcbind services are not in use
# This script stops and masks rpcbind services

set -e

echo "CIS 2.2.12 - Disabling rpcbind services..."

# Stop rpcbind services if running
if systemctl is-active rpcbind.socket &>/dev/null; then
    echo "Stopping rpcbind.socket..."
    systemctl stop rpcbind.socket
fi

if systemctl is-active rpcbind.service &>/dev/null; then
    echo "Stopping rpcbind.service..."
    systemctl stop rpcbind.service
fi

# Mask rpcbind services to prevent them from being started
systemctl mask rpcbind.socket 2>/dev/null || true
systemctl mask rpcbind.service 2>/dev/null || true

echo "CIS 2.2.12 remediation complete - rpcbind services are stopped and masked."