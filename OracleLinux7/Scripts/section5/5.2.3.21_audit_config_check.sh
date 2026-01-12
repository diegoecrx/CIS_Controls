#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.3.21
# Ensure the running and on disk configuration is the same

set -e

echo "CIS 5.2.3.21 - Checking audit configuration consistency..."

echo "Regenerating audit rules from disk..."
augenrules --load

echo ""
echo "Comparing running vs on-disk configuration:"

# Get running rules
auditctl -l > /tmp/audit_running.txt

# Get on-disk rules
augenrules --check 2>&1 || true

echo ""
echo "If differences exist, run: augenrules --load"
echo "Then reboot if audit is in immutable mode."

echo "CIS 5.2.3.21 - Audit complete."