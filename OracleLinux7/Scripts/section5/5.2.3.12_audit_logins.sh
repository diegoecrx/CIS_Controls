#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.12
# Ensure login and logout events are collected

set -e

echo "CIS 5.2.3.12 - Configuring login/logout audit rules..."

cat > /etc/audit/rules.d/50-login.rules << 'EOF'
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k logins
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep logins

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.12 remediation complete."