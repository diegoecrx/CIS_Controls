#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.6
# Ensure password maximum sequential characters is configured
# This script configures maxsequence in pwquality.conf

set -e

echo "CIS 4.4.2.2.6 - Configuring password maxsequence..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out existing maxsequence and add new setting
sed -ri 's/^\s*maxsequence\s*=/# &/' /etc/security/pwquality.conf
echo "maxsequence = 3" >> /etc/security/pwquality.conf

echo "Verifying configuration:"
grep -i "maxsequence" /etc/security/pwquality.conf

echo "CIS 4.4.2.2.6 remediation complete."