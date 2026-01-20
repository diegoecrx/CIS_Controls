#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.1
# Ensure the audit log directory is 0750 or more restrictive

set -e

echo "CIS 5.2.4.1 - Configuring audit log directory permissions..."

AUDIT_LOG_DIR=$(dirname $(awk -F"=" '/^\s*log_file\s*=\s*/ {print $2}' /etc/audit/auditd.conf))

chmod g-w,o-rwx "${AUDIT_LOG_DIR}"

echo "Verifying permissions:"
stat -Lc "%n %a" "${AUDIT_LOG_DIR}"

echo "CIS 5.2.4.1 remediation complete."