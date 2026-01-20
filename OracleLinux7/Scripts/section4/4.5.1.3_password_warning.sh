#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.5.1.3
# Ensure password expiration warning days is 7 or more
# This script configures PASS_WARN_AGE

set -e

echo "CIS 4.5.1.3 - Configuring password expiration warning..."

# Backup login.defs
cp /etc/login.defs /etc/login.defs.backup.$(date +%Y%m%d%H%M%S)

# Configure PASS_WARN_AGE
if grep -q "^PASS_WARN_AGE" /etc/login.defs; then
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs
else
    echo "PASS_WARN_AGE 7" >> /etc/login.defs
fi

echo "Verifying configuration:"
grep "^PASS_WARN_AGE" /etc/login.defs

echo ""
echo "NOTE: To update existing users, run:"
echo "  chage --warndays 7 <username>"

echo "CIS 4.5.1.3 remediation complete."