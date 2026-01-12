#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.10
# Ensure successful file system mounts are collected

set -e

echo "CIS 5.2.3.10 - Configuring mount audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-mounts.rules << EOF
-a always,exit -F arch=b64 -S mount -F auid>=${UID_MIN} -F auid!=unset -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=${UID_MIN} -F auid!=unset -k mounts
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep mounts

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.10 remediation complete."