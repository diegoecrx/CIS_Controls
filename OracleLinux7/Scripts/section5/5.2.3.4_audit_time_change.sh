#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.4
# Ensure events that modify date and time information are collected

set -e

echo "CIS 5.2.3.4 - Configuring date/time audit rules..."

cat > /etc/audit/rules.d/50-time-change.rules << 'EOF'
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change
-w /etc/localtime -p wa -k time-change
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep time-change

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.4 remediation complete."