#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.2.3
# Ensure system is disabled when audit logs are full

set -e

echo "CIS 5.2.2.3 - Configuring audit disk full action..."

# Backup
cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure disk_full_action
if grep -q "^disk_full_action" /etc/audit/auditd.conf; then
    sed -i 's/^disk_full_action.*/disk_full_action = halt/' /etc/audit/auditd.conf
else
    echo "disk_full_action = halt" >> /etc/audit/auditd.conf
fi

# Configure disk_error_action
if grep -q "^disk_error_action" /etc/audit/auditd.conf; then
    sed -i 's/^disk_error_action.*/disk_error_action = halt/' /etc/audit/auditd.conf
else
    echo "disk_error_action = halt" >> /etc/audit/auditd.conf
fi

echo "Verifying configuration:"
grep -E "^disk_full_action|^disk_error_action" /etc/audit/auditd.conf

echo ""
echo "WARNING: System will halt when audit logs are full or on disk error."
echo "Adjust to 'single' if preferred."

echo "CIS 5.2.2.3 remediation complete."