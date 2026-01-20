#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.10
# Ensure nis server services are not in use
# This script stops and masks ypserv service

set -e

echo "CIS 2.2.10 - Disabling NIS server services..."

# Stop ypserv service if running
if systemctl is-active ypserv.service &>/dev/null; then
    echo "Stopping ypserv.service..."
    systemctl stop ypserv.service
fi

# Mask ypserv service to prevent it from being started
systemctl mask ypserv.service 2>/dev/null || true

echo "CIS 2.2.10 remediation complete - NIS server service is stopped and masked."