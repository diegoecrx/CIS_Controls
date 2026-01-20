#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.2.6
# Ensure iptables is enabled and running
# This script enables and starts the iptables service

set -e

echo "CIS 3.4.4.2.6 - Enabling iptables service..."

# Stop and disable conflicting services
systemctl stop firewalld 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true
systemctl stop nftables 2>/dev/null || true
systemctl disable nftables 2>/dev/null || true

# Enable and start iptables
systemctl enable iptables
systemctl start iptables

echo "Verifying iptables status:"
systemctl is-enabled iptables
systemctl status iptables --no-pager || true

echo "CIS 3.4.4.2.6 remediation complete."