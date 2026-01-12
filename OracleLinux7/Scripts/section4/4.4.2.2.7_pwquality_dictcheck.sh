#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.7
# Ensure password dictionary check is enabled
# This script enables dictcheck in pwquality.conf

set -e

echo "CIS 4.4.2.2.7 - Enabling password dictionary check..."

# Backup pwquality.conf
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup.$(date +%Y%m%d%H%M%S)

# Comment out any dictcheck = 0 entries
sed -ri 's/^\s*dictcheck\s*=/# &/' /etc/security/pwquality.conf

echo "Verifying configuration (dictcheck should not be set to 0):"
grep -i "dictcheck" /etc/security/pwquality.conf || echo "dictcheck not explicitly set (enabled by default)"

echo "CIS 4.4.2.2.7 remediation complete."