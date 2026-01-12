#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.5
# Ensure password same consecutive characters is configured
# This script configures maxrepeat in pwquality.conf

set -e

echo "CIS 4.4.2.2.5 - Configuring password maxrepeat..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out existing maxrepeat and add new setting
sed -ri 's/^\s*maxrepeat\s*=/# &/' /etc/security/pwquality.conf
echo "maxrepeat = 3" >> /etc/security/pwquality.conf

echo "Verifying configuration:"
grep -i "maxrepeat" /etc/security/pwquality.conf

echo "CIS 4.4.2.2.5 remediation complete."