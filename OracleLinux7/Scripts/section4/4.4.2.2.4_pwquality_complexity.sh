#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.4
# Ensure password complexity is configured
# This script configures minclass in pwquality.conf

set -e

echo "CIS 4.4.2.2.4 - Configuring password complexity..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out existing settings and add new
sed -ri 's/^\s*minclass\s*=/# &/' /etc/security/pwquality.conf
echo "minclass = 4" >> /etc/security/pwquality.conf

echo "Verifying configuration:"
grep -Ei "minclass|dcredit|ucredit|lcredit|ocredit" /etc/security/pwquality.conf

echo "CIS 4.4.2.2.4 remediation complete."