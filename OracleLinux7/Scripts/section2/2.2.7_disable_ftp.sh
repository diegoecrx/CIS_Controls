#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.7
# Ensure ftp server services are not in use
# This script stops and masks vsftpd service

set -e

echo "CIS 2.2.7 - Disabling FTP server services..."

# Stop vsftpd service if running
if systemctl is-active vsftpd.service &>/dev/null; then
    echo "Stopping vsftpd.service..."
    systemctl stop vsftpd.service
fi

# Mask vsftpd service to prevent it from being started
systemctl mask vsftpd.service 2>/dev/null || true

echo "CIS 2.2.7 remediation complete - FTP server service is stopped and masked."