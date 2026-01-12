#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.3.4
# Ensure users must provide password for escalation
# This script checks for NOPASSWD entries - MANUAL REVIEW

set -e

echo "CIS 4.3.4 - Checking for NOPASSWD entries..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Searching for NOPASSWD entries in sudoers files:"
grep -ri "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || echo "No NOPASSWD entries found - COMPLIANT"

echo ""
echo "If NOPASSWD entries exist, use visudo to remove them."
echo "WARNING: This may affect automated processes (Ansible, AWS builds, etc.)"

echo "CIS 4.3.4 check complete - manual review required."