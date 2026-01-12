#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.7
# Ensure no duplicate group names exist
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.7 - Checking for duplicate group names..."
echo "=============================================================="
echo "NOTE: This script identifies issues - manual remediation required."
echo ""

found_dup=0
cut -f1 -d: /etc/group | sort | uniq -d | while read groupname; do
    echo " - Duplicate group name found: $groupname"
    found_dup=1
done

if [ $found_dup -eq 0 ]; then
    echo "No duplicate group names found."
else
    echo ""
    echo "=============================================================="
    echo "Establish unique group names for duplicate groups."
fi

echo "CIS 6.2.7 audit complete."