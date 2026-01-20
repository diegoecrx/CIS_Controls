#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.9
# Ensure discretionary access control permission modification events are collected

set -e

echo "CIS 5.2.3.9 - Configuring DAC permission audit rules..."

UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

cat > /etc/audit/rules.d/50-perm_mod.rules << EOF
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S chown,fchown,lchown,fchownat -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=${UID_MIN} -F auid!=unset -k perm_mod
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep perm_mod | head -2

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.9 remediation complete."