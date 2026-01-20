#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.7
# Ensure audit configuration files belong to group root

set -e

echo "CIS 5.2.4.7 - Configuring audit config file group ownership..."

find /etc/audit/ -type f \( -name "*.conf" -o -name "*.rules" \) -exec chgrp root {} +

echo "Verifying group ownership:"
ls -la /etc/audit/*.conf /etc/audit/rules.d/*.rules 2>/dev/null | head -10

echo "CIS 5.2.4.7 remediation complete."