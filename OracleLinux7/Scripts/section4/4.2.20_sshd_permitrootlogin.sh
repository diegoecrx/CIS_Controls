#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.20
# Ensure sshd PermitRootLogin is disabled
# WARNING: This affects root SSH access - PRINT ONLY

set -e

echo "CIS 4.2.20 - Checking sshd PermitRootLogin..."
echo "=============================================="
echo "WARNING: THIS SCRIPT DOES NOT APPLY CHANGES"
echo "Disabling root login may lock you out if no other admin user exists!"
echo "=============================================="
echo ""

echo "Current PermitRootLogin setting:"
grep -Ei "^\s*PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null || echo "PermitRootLogin not explicitly set (default may apply)"

echo ""
echo "To disable root login, add to /etc/ssh/sshd_config:"
echo "  PermitRootLogin no"
echo ""
echo "Then run: systemctl reload-or-try-restart sshd.service"
echo ""
echo "IMPORTANT: Ensure you have another user with sudo access before disabling root login!"

echo "CIS 4.2.20 check complete - manual action required."