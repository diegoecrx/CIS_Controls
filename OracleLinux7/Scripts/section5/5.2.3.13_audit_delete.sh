#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.13
# Ensure file deletion events by users are collected

set -e

echo "CIS 5.2.3.13 - Configuring file deletion audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-delete.rules << EOF
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=${UID_MIN} -F auid!=unset -k delete
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=${UID_MIN} -F auid!=unset -k delete
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep delete

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.13 remediation complete."