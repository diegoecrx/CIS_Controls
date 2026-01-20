#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.5
# Ensure audit configuration files are 640 or more restrictive

set -e

echo "CIS 5.2.4.5 - Configuring audit config file permissions..."

find /etc/audit/ -type f \( -name "*.conf" -o -name "*.rules" \) -exec chmod u-x,g-wx,o-rwx {} +

echo "Verifying permissions:"
ls -la /etc/audit/*.conf /etc/audit/rules.d/*.rules 2>/dev/null | head -10

echo "CIS 5.2.4.5 remediation complete."