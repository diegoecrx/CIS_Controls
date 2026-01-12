#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.2.22
# Ensure only approved services are listening on a network interface
# This script lists listening services for manual review

set -e

echo "CIS 2.2.22 - Checking network listening services..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""
echo "The following services are listening on network interfaces:"
echo ""

# List all listening TCP and UDP services
ss -plntu

echo ""
echo "=============================================="
echo "Review the output above and ensure only approved services are listening."
echo "For any unauthorized service, run:"
echo "  systemctl stop <service>.socket <service>.service"
echo "  systemctl mask <service>.socket <service>.service"
echo "=============================================="

echo "CIS 2.2.22 remediation complete - manual review required."