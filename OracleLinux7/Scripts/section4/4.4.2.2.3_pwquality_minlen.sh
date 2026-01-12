#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.3
# Ensure password length is configured
# This script configures minlen in pwquality.conf

set -e

echo "CIS 4.4.2.2.3 - Configuring password minlen..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out existing minlen and add new setting
sed -ri 's/^\s*minlen\s*=/# &/' /etc/security/pwquality.conf
echo "minlen = 14" >> /etc/security/pwquality.conf

echo "Verifying configuration:"
grep -i "minlen" /etc/security/pwquality.conf

echo "CIS 4.4.2.2.3 remediation complete."