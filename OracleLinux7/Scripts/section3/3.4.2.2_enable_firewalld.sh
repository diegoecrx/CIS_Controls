#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.2.2
# Ensure firewalld service enabled and running
# This script enables and starts firewalld

set -e

echo "CIS 3.4.2.2 - Enabling firewalld service..."
echo "=============================================="
echo "WARNING: Changing firewall settings while connected"
echo "over network can result in being locked out."
echo "=============================================="

# Unmask firewalld
systemctl unmask firewalld 2>/dev/null || true

# Enable and start firewalld
systemctl enable firewalld
systemctl start firewalld

echo "CIS 3.4.2.2 remediation complete - firewalld enabled and running."