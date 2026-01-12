#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.4.2
# Ensure audit log files are mode 0640 or less permissive

set -e

echo "CIS 5.2.4.2 - Configuring audit log file permissions..."

AUDIT_LOG_FILE=$(awk -F"=" '/^\s*log_file\s*=\s*/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
AUDIT_LOG_DIR=$(dirname "${AUDIT_LOG_FILE}")

# Set permissions on all audit log files
find "${AUDIT_LOG_DIR}" -type f \( -name "*.log" -o -name "*.log.*" \) -exec chmod u-x,g-wx,o-rwx {} +

echo "Verifying permissions:"
ls -la "${AUDIT_LOG_DIR}" | head -10

echo "CIS 5.2.4.2 remediation complete."