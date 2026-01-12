#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.3.5
# Ensure re-authentication for privilege escalation is not disabled globally
# This script checks for !authenticate entries - MANUAL REVIEW

set -e

echo "CIS 4.3.5 - Checking for !authenticate entries..."
echo "=============================================="
echo "MANUAL REVIEW REQUIRED"
echo "=============================================="
echo ""

echo "Searching for !authenticate entries in sudoers files:"
grep -ri "!authenticate" /etc/sudoers /etc/sudoers.d/ 2>/dev/null || echo "No !authenticate entries found - COMPLIANT"

echo ""
echo "If !authenticate entries exist, use visudo to remove them."

echo "CIS 4.3.5 check complete - manual review required."