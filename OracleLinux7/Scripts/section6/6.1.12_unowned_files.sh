#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.1.12
# Ensure no unowned or ungrouped files or directories exist
# NOTE: This script identifies files - manual review required

echo "CIS 6.1.12 - Checking for unowned or ungrouped files/directories..."
echo "=============================================================="
echo "NOTE: This script identifies issues but requires manual remediation."
echo "Review the output and assign appropriate ownership."
echo ""

echo "Searching for unowned files (no valid user)..."
find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null | while read -r file; do
    echo " - Unowned: $file"
done

echo ""
echo "Searching for ungrouped files (no valid group)..."
find / -xdev \( -type f -o -type d \) -nogroup 2>/dev/null | while read -r file; do
    echo " - Ungrouped: $file"
done

echo ""
echo "=============================================================="
echo "To remediate, run: chown <user>:<group> <file>"
echo "CIS 6.1.12 audit complete."