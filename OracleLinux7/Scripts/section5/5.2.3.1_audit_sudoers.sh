#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.1
# Ensure changes to system administration scope (sudoers) is collected

set -e

echo "CIS 5.2.3.1 - Configuring sudoers audit rules..."

# Create audit rule file
cat > /etc/audit/rules.d/50-scope.rules << 'EOF'
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d -p wa -k scope
EOF

# Load rules
augenrules --load

echo "Verifying rules:"
auditctl -l | grep scope

# Check if reboot required
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    echo ""
    echo "NOTE: Reboot required to load rules."
fi

echo "CIS 5.2.3.1 remediation complete."