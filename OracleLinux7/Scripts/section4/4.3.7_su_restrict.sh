#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.3.7
# Ensure access to the su command is restricted
# This script restricts su command access

set -e

echo "CIS 4.3.7 - Restricting access to su command..."

# Create empty sugroup if it doesn't exist
if ! grep -q "^sugroup:" /etc/group; then
    echo "Creating sugroup..."
    groupadd sugroup
fi

# Check if pam_wheel.so is configured in /etc/pam.d/su
if grep -Pq '^\s*auth\s+required\s+pam_wheel\.so.*group=sugroup' /etc/pam.d/su; then
    echo "pam_wheel.so already configured for sugroup."
else
    echo "Adding pam_wheel.so configuration to /etc/pam.d/su..."
    # Backup
    cp /etc/pam.d/su /etc/pam.d/su.backup.$(date +%Y%m%d%H%M%S)
    # Add the line after the first auth line
    sed -i '/^auth.*pam_rootok/a auth required pam_wheel.so use_uid group=sugroup' /etc/pam.d/su
fi

echo "Verifying configuration:"
grep pam_wheel /etc/pam.d/su
echo ""
echo "sugroup members:"
grep "^sugroup:" /etc/group

echo "CIS 4.3.7 remediation complete."