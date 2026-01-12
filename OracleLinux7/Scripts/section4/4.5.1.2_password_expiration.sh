#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.1.2
# Ensure password expiration is 365 days or less
# This script configures PASS_MAX_DAYS

set -e

echo "CIS 4.5.1.2 - Configuring password expiration..."

# Backup login.defs
cp /etc/login.defs /etc/login.defs.backup.$(date +%Y%m%d%H%M%S)

# Configure PASS_MAX_DAYS
if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 365/' /etc/login.defs
else
    echo "PASS_MAX_DAYS 365" >> /etc/login.defs
fi

echo "Verifying configuration:"
grep "^PASS_MAX_DAYS" /etc/login.defs

echo ""
echo "NOTE: To update existing users, run:"
echo "  chage --maxdays 365 <username>"

echo "CIS 4.5.1.2 remediation complete."