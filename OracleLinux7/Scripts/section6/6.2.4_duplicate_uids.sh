#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.4
# Ensure no duplicate UIDs exist
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.4 - Checking for duplicate UIDs..."
echo "=============================================================="
echo "NOTE: This script identifies issues - manual remediation required."
echo ""

found_dup=0
cut -f3 -d: /etc/passwd | sort -n | uniq -d | while read uid; do
    echo " - Duplicate UID ($uid) found for users:"
    awk -F: -v uid="$uid" '($3 == uid) { print "   - " $1 }' /etc/passwd
    found_dup=1
done

if [ $found_dup -eq 0 ]; then
    echo "No duplicate UIDs found."
else
    echo ""
    echo "=============================================================="
    echo "Establish unique UIDs and review file ownership."
fi

echo "CIS 6.2.4 audit complete."