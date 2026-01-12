#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.4
# Ensure sshd access is configured
# This script displays current SSH access configuration - MANUAL REVIEW

set -e

echo "CIS 4.2.4 - Checking sshd access configuration..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Current SSH access settings:"
grep -Ei '^\s*(Allow|Deny)(Users|Groups)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null || echo "No Allow/Deny directives found"

echo ""
echo "To restrict SSH access, edit /etc/ssh/sshd_config and add one of:"
echo "  AllowUsers <userlist>"
echo "  AllowGroups <grouplist>"
echo "  DenyUsers <userlist>"
echo "  DenyGroups <grouplist>"
echo ""
echo "Then run: systemctl reload-or-try-restart sshd.service"

echo "CIS 4.2.4 remediation complete - manual review required."