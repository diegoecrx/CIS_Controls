#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.3.8
# Ensure nftables service is enabled and active
# This script enables nftables service

set -e

echo "CIS 3.4.3.8 - Enabling nftables service..."

# Unmask nftables service
systemctl unmask nftables.service 2>/dev/null || true

# Enable and start nftables service
systemctl enable nftables.service
systemctl start nftables.service

echo "CIS 3.4.3.8 remediation complete - nftables service enabled."