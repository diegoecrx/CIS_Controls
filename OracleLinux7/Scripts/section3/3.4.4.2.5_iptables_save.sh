#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.4.2.5
# Ensure iptables rules are saved
# This script saves the current iptables rules

set -e

echo "CIS 3.4.4.2.5 - Saving iptables rules..."

# Backup existing rules file if exists
if [ -f /etc/sysconfig/iptables ]; then
    cp /etc/sysconfig/iptables /etc/sysconfig/iptables.backup.$(date +%Y%m%d%H%M%S)
    echo "Existing rules backed up."
fi

# Save current rules
service iptables save 2>/dev/null || iptables-save > /etc/sysconfig/iptables

echo "Current saved rules:"
cat /etc/sysconfig/iptables

echo "CIS 3.4.4.2.5 remediation complete."