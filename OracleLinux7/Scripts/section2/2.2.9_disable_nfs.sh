#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.9
# Ensure network file system services are not in use
# This script stops and masks nfs-server service

set -e

echo "CIS 2.2.9 - Disabling NFS server services..."

# Stop nfs-server service if running
if systemctl is-active nfs-server.service &>/dev/null; then
    echo "Stopping nfs-server.service..."
    systemctl stop nfs-server.service
fi

# Mask nfs-server service to prevent it from being started
systemctl mask nfs-server.service 2>/dev/null || true

echo "CIS 2.2.9 remediation complete - NFS server service is stopped and masked."