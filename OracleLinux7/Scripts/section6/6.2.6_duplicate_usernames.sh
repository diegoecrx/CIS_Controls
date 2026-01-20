#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.2.6
# Ensure no duplicate user names exist
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.6 - Checking for duplicate user names..."
echo "=============================================================="
echo "NOTE: This script identifies issues - manual remediation required."
echo ""

found_dup=0
cut -f1 -d: /etc/passwd | sort | uniq -d | while read username; do
    echo " - Duplicate username found: $username"
    found_dup=1
done

if [ $found_dup -eq 0 ]; then
    echo "No duplicate user names found."
else
    echo ""
    echo "=============================================================="
    echo "Establish unique user names for duplicate accounts."
fi

echo "CIS 6.2.6 audit complete."