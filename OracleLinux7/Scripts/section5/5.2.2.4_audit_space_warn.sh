#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.2.4
# Ensure system warns when audit logs are low on space

set -e

echo "CIS 5.2.2.4 - Configuring audit space warnings..."

# Backup
cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure space_left_action
if grep -q "^space_left_action" /etc/audit/auditd.conf; then
    sed -i 's/^space_left_action.*/space_left_action = email/' /etc/audit/auditd.conf
else
    echo "space_left_action = email" >> /etc/audit/auditd.conf
fi

# Configure admin_space_left_action
if grep -q "^admin_space_left_action" /etc/audit/auditd.conf; then
    sed -i 's/^admin_space_left_action.*/admin_space_left_action = single/' /etc/audit/auditd.conf
else
    echo "admin_space_left_action = single" >> /etc/audit/auditd.conf
fi

echo "Verifying configuration:"
grep -E "^space_left_action|^admin_space_left_action" /etc/audit/auditd.conf

echo ""
echo "NOTE: Ensure MTA is configured for email alerts to work."

echo "CIS 5.2.2.4 remediation complete."