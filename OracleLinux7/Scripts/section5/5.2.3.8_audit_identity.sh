#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.8
# Ensure events that modify user/group information are collected

set -e

echo "CIS 5.2.3.8 - Configuring user/group audit rules..."

cat > /etc/audit/rules.d/50-identity.rules << 'EOF'
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep identity | head -3

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.8 remediation complete."