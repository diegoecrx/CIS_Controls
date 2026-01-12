#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.15
# Ensure telnet server services are not in use
# This script stops and masks telnet socket
# NOTE: This affects remote access - prints warning only per OCI requirements

set -e

echo "CIS 2.2.15 - Disabling telnet server services..."
echo "=============================================="
echo "WARNING: This control affects remote access services."
echo "Telnet server should be disabled in favor of SSH."
echo "=============================================="

# Stop telnet socket if running
if systemctl is-active telnet.socket &>/dev/null; then
    echo "Stopping telnet.socket..."
    systemctl stop telnet.socket
fi

# Mask telnet socket to prevent it from being started
systemctl mask telnet.socket 2>/dev/null || true

echo "CIS 2.2.15 remediation complete - telnet server is stopped and masked."