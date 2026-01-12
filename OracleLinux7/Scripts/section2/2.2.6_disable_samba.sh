#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.6
# Ensure samba file server services are not in use
# This script stops and masks smb service

set -e

echo "CIS 2.2.6 - Disabling Samba file server services..."

# Stop smb service if running
if systemctl is-active smb.service &>/dev/null; then
    echo "Stopping smb.service..."
    systemctl stop smb.service
fi

# Mask smb service to prevent it from being started
systemctl mask smb.service 2>/dev/null || true

echo "CIS 2.2.6 remediation complete - Samba file server service is stopped and masked."