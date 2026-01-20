#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.14
# Ensure events that modify the system's Mandatory Access Controls are collected

set -e

echo "CIS 5.2.3.14 - Configuring MAC audit rules..."

cat > /etc/audit/rules.d/50-MAC-policy.rules << 'EOF'
-w /etc/selinux -p wa -k MAC-policy
-w /usr/share/selinux -p wa -k MAC-policy
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep MAC-policy

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.14 remediation complete."