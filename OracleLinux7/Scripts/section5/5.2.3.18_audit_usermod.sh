#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.18
# Ensure successful and unsuccessful attempts to use the usermod command are recorded

set -e

echo "CIS 5.2.3.18 - Configuring usermod audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-usermod.rules << EOF
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k usermod
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep usermod

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.18 remediation complete."