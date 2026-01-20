#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.6
# Ensure audit configuration files are owned by root

set -e

echo "CIS 5.2.4.6 - Configuring audit config file ownership..."

find /etc/audit/ -type f \( -name "*.conf" -o -name "*.rules" \) -exec chown root {} +

echo "Verifying ownership:"
ls -la /etc/audit/*.conf /etc/audit/rules.d/*.rules 2>/dev/null | head -10

echo "CIS 5.2.4.6 remediation complete."