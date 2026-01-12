#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.3
# Ensure all groups in /etc/passwd exist in /etc/group
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.3 - Checking for groups in /etc/passwd not in /etc/group..."
echo "=============================================================="
echo "NOTE: This script identifies issues - manual remediation required."
echo ""

found_issue=0
for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
    grep -q -P "^.*?:[^:]*:$i:" /etc/group
    if [ $? -ne 0 ]; then
        echo " - Group GID $i referenced in /etc/passwd is not in /etc/group"
        found_issue=1
    fi
done

if [ $found_issue -eq 0 ]; then
    echo "All groups in /etc/passwd exist in /etc/group."
else
    echo ""
    echo "=============================================================="
    echo "Create missing groups or update user's primary group."
fi

echo "CIS 6.2.3 audit complete."