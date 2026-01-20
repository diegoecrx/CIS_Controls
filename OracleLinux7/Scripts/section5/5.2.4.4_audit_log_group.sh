#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.4
# Ensure only authorized groups are assigned ownership of audit log files

set -e

echo "CIS 5.2.4.4 - Configuring audit log group ownership..."

AUDIT_LOG_FILE=$(awk -F"=" '/^\s*log_file\s*=\s*/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
AUDIT_LOG_DIR=$(dirname "${AUDIT_LOG_FILE}")

# Set group ownership on all audit log files
find "${AUDIT_LOG_DIR}" -type f -exec chgrp root {} +

# Configure auditd.conf log_group
if grep -q "^log_group" /etc/audit/auditd.conf; then
    sed -i 's/^log_group.*/log_group = root/' /etc/audit/auditd.conf
else
    echo "log_group = root" >> /etc/audit/auditd.conf
fi

echo "Verifying group ownership:"
ls -la "${AUDIT_LOG_DIR}" | head -10

echo "CIS 5.2.4.4 remediation complete."