#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.16
# Ensure successful and unsuccessful attempts to use the setfacl command are recorded

set -e

echo "CIS 5.2.3.16 - Configuring setfacl audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Append to existing perm_chng rules
cat >> /etc/audit/rules.d/50-perm_chng.rules << EOF
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep setfacl

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.16 remediation complete."