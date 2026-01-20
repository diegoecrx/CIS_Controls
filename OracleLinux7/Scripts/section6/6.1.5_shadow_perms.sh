#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.5
# Ensure permissions on /etc/shadow are configured

set -e

echo "CIS 6.1.5 - Configuring /etc/shadow permissions..."

chmod 0000 /etc/shadow
chown root:root /etc/shadow

echo "Verifying permissions:"
stat -c "%n %a %U:%G" /etc/shadow

echo "CIS 6.1.5 remediation complete."