#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.2.1
# Ensure audit log storage size is configured

set -e

echo "CIS 5.2.2.1 - Configuring audit log storage size..."

# Backup
cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak.$(date +%Y%m%d)

# Configure max_log_file (32MB is typical)
if grep -q "^max_log_file" /etc/audit/auditd.conf; then
    sed -i 's/^max_log_file.*/max_log_file = 32/' /etc/audit/auditd.conf
else
    echo "max_log_file = 32" >> /etc/audit/auditd.conf
fi

echo "Verifying configuration:"
grep -E "^max_log_file" /etc/audit/auditd.conf

echo ""
echo "NOTE: Adjust value according to site policy."

echo "CIS 5.2.2.1 remediation complete."