#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.3.5
# Ensure ip6tables rules are saved
# This script saves the current ip6tables rules

set -e

echo "CIS 3.4.4.3.5 - Saving ip6tables rules..."

# Backup existing rules file if exists
if [ -f /etc/sysconfig/ip6tables ]; then
    cp /etc/sysconfig/ip6tables /etc/sysconfig/ip6tables.backup.$(date +%Y%m%d%H%M%S)
    echo "Existing rules backed up."
fi

# Save current rules
service ip6tables save 2>/dev/null || ip6tables-save > /etc/sysconfig/ip6tables

echo "Current saved rules:"
cat /etc/sysconfig/ip6tables

echo "CIS 3.4.4.3.5 remediation complete."