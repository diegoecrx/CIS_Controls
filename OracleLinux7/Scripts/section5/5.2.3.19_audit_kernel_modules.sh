#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.19
# Ensure kernel module loading, unloading and modification is collected

set -e

echo "CIS 5.2.3.19 - Configuring kernel module audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-kernel_modules.rules << EOF
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module,create_module,query_module -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k kernel_modules
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep kernel_modules | head -2

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.19 remediation complete."