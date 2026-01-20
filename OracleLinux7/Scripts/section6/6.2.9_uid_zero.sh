#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.2.9
# Ensure root is the only UID 0 account
# NOTE: This script identifies - DOES NOT automatically remove accounts

echo "CIS 6.2.9 - Checking for accounts with UID 0..."
echo "=============================================================="
echo "WARNING: This script identifies UID 0 accounts."
echo "Only 'root' should have UID 0. Manual review required."
echo ""

uid_zero=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd)

echo "Accounts with UID 0:"
for user in $uid_zero; do
    if [ "$user" = "root" ]; then
        echo " - $user (expected)"
    else
        echo " - $user (UNEXPECTED - should be removed or assigned new UID)"
    fi
done

echo ""
echo "=============================================================="
echo "If non-root accounts have UID 0, remove them or assign new UID."
echo "CIS 6.2.9 audit complete."