#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.15
# Ensure successful and unsuccessful attempts to use the chcon command are recorded

set -e

echo "CIS 5.2.3.15 - Configuring chcon audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-perm_chng.rules << EOF
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep perm_chng

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.15 remediation complete."