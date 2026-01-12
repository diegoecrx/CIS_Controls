#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.5
# Ensure no duplicate GIDs exist
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.5 - Checking for duplicate GIDs..."
echo "=============================================================="
echo "NOTE: This script identifies issues - manual remediation required."
echo ""

found_dup=0
cut -f3 -d: /etc/group | sort -n | uniq -d | while read gid; do
    echo " - Duplicate GID ($gid) found for groups:"
    awk -F: -v gid="$gid" '($3 == gid) { print "   - " $1 }' /etc/group
    found_dup=1
done

if [ $found_dup -eq 0 ]; then
    echo "No duplicate GIDs found."
else
    echo ""
    echo "=============================================================="
    echo "Establish unique GIDs and review file group ownership."
fi

echo "CIS 6.2.5 audit complete."