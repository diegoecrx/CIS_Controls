#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.3
# Ensure only authorized users own audit log files

set -e

echo "CIS 5.2.4.3 - Configuring audit log file ownership..."

AUDIT_LOG_FILE=$(awk -F"=" '/^\s*log_file\s*=\s*/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
AUDIT_LOG_DIR=$(dirname "${AUDIT_LOG_FILE}")

# Set ownership on all audit log files
find "${AUDIT_LOG_DIR}" -type f -exec chown root {} +

echo "Verifying ownership:"
ls -la "${AUDIT_LOG_DIR}" | head -10

echo "CIS 5.2.4.3 remediation complete."