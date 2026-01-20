#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.2
# Ensure password number of changed characters is configured
# This script configures difok in pwquality.conf

set -e

echo "CIS 4.4.2.2.2 - Configuring password difok..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out existing difok and add new setting
sed -ri 's/^\s*difok\s*=/# &/' /etc/security/pwquality.conf
echo "difok = 2" >> /etc/security/pwquality.conf

echo "Verifying configuration:"
grep -i "difok" /etc/security/pwquality.conf

echo "CIS 4.4.2.2.2 remediation complete."