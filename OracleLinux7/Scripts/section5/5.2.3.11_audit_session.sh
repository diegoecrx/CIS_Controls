#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.11
# Ensure session initiation information is collected

set -e

echo "CIS 5.2.3.11 - Configuring session audit rules..."

cat > /etc/audit/rules.d/50-session.rules << 'EOF'
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | grep session

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "NOTE: Reboot required."; fi

echo "CIS 5.2.3.11 remediation complete."