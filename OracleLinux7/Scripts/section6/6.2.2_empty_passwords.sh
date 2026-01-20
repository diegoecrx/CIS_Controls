#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.2.2
# Ensure /etc/shadow password fields are not empty
# NOTE: This script identifies and locks accounts - review carefully

echo "CIS 6.2.2 - Checking for accounts without passwords..."
echo "=============================================================="
echo "NOTE: Accounts without passwords will be LOCKED."
echo "Review output carefully before running in production."
echo ""

# Find accounts without passwords
empty_pass=$(/bin/awk -F: '($2 == "") { print $1 }' /etc/shadow)

if [ -n "$empty_pass" ]; then
    echo "Found accounts without passwords:"
    for user in $empty_pass; do
        echo " - Locking account: $user"
        passwd -l "$user"
    done
    echo ""
    echo "Accounts have been locked. Investigate why they had no password."
else
    echo "All accounts have passwords set."
fi

echo "CIS 6.2.2 remediation complete."