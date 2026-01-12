#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.2.2
# Ensure audit logs are not automatically deleted

set -e

echo "CIS 5.2.2.2 - Configuring audit log retention..."

# Backup
cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure max_log_file_action
if grep -q "^max_log_file_action" /etc/audit/auditd.conf; then
    sed -i 's/^max_log_file_action.*/max_log_file_action = keep_logs/' /etc/audit/auditd.conf
else
    echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
fi

echo "Verifying configuration:"
grep -E "^max_log_file_action" /etc/audit/auditd.conf

echo "CIS 5.2.2.2 remediation complete."