#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.3.20
# Ensure the audit configuration is immutable

set -e

echo "CIS 5.2.3.20 - Configuring immutable audit rules..."

# This should be the last rule in the audit configuration
cat > /etc/audit/rules.d/99-finalize.rules << 'EOF'
-e 2
EOF

augenrules --load

echo "Verifying rules:"
auditctl -l | tail -3

echo ""
echo "NOTE: With -e 2, audit rules cannot be changed without a reboot."

if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then echo "Reboot required to apply immutable setting."; fi

echo "CIS 5.2.3.20 remediation complete."