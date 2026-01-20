#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.5
# Ensure events that modify the system's network environment are collected

set -e

echo "CIS 5.2.3.5 - Configuring network environment audit rules..."

cat > /etc/audit/rules.d/50-system_locale.rules << 'EOF'
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale
-w /etc/sysconfig/network-scripts/ -p wa -k system-locale
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep system-locale | head -5

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.5 remediation complete."