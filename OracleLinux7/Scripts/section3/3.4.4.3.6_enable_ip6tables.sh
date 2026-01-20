#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.6
# Ensure ip6tables is enabled and running
# This script enables and starts the ip6tables service

set -e

echo "CIS 3.4.4.3.6 - Enabling ip6tables service..."

# Stop and disable conflicting services
systemctl stop firewalld 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true
systemctl stop nftables 2>/dev/null || true
systemctl disable nftables 2>/dev/null || true

# Enable and start ip6tables
systemctl enable ip6tables
systemctl start ip6tables

echo "Verifying ip6tables status:"
systemctl is-enabled ip6tables
systemctl status ip6tables --no-pager || true

echo "CIS 3.4.4.3.6 remediation complete."