#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.2
# Ensure avahi daemon services are not in use
# This script stops and masks avahi services

set -e

echo "CIS 2.2.2 - Disabling avahi daemon services..."

# Stop avahi services if running
if systemctl is-active avahi-daemon.socket &>/dev/null; then
    echo "Stopping avahi-daemon.socket..."
    systemctl stop avahi-daemon.socket
fi

if systemctl is-active avahi-daemon.service &>/dev/null; then
    echo "Stopping avahi-daemon.service..."
    systemctl stop avahi-daemon.service
fi

# Mask avahi services to prevent them from being started
systemctl mask avahi-daemon.socket 2>/dev/null || true
systemctl mask avahi-daemon.service 2>/dev/null || true

echo "CIS 2.2.2 remediation complete - avahi daemon services are stopped and masked."