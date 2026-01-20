#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.2
# Ensure actions as another user are always logged

set -e

echo "CIS 5.2.3.2 - Configuring user emulation audit rules..."

# Create audit rule file
cat > /etc/audit/rules.d/50-user_emulation.rules << 'EOF'
-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation
EOF

# Load rules
augenrules --load

echo "Verifying rules:"
auditctl -l | grep user_emulation

# Check if reboot required
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    echo ""
    echo "NOTE: Reboot required to load rules."
fi

echo "CIS 5.2.3.2 remediation complete."