#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.18
# Ensure web server services are not in use
# This script stops and masks httpd and nginx services

set -e

echo "CIS 2.2.18 - Disabling web server services..."

# Stop httpd services if running
if systemctl is-active httpd.socket &>/dev/null; then
    echo "Stopping httpd.socket..."
    systemctl stop httpd.socket
fi

if systemctl is-active httpd.service &>/dev/null; then
    echo "Stopping httpd.service..."
    systemctl stop httpd.service
fi

if systemctl is-active nginx.service &>/dev/null; then
    echo "Stopping nginx.service..."
    systemctl stop nginx.service
fi

# Mask web server services to prevent them from being started
systemctl mask httpd.socket 2>/dev/null || true
systemctl mask httpd.service 2>/dev/null || true
systemctl mask nginx.service 2>/dev/null || true

echo "CIS 2.2.18 remediation complete - web server services are stopped and masked."