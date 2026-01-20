#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.17
# Ensure web proxy server services are not in use
# This script stops and masks squid service

set -e

echo "CIS 2.2.17 - Disabling web proxy server services..."

# Stop squid service if running
if systemctl is-active squid.service &>/dev/null; then
    echo "Stopping squid.service..."
    systemctl stop squid.service
fi

# Mask squid service to prevent it from being started
systemctl mask squid.service 2>/dev/null || true

echo "CIS 2.2.17 remediation complete - web proxy server service is stopped and masked."