#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.1
# Ensure permissions on /etc/passwd are configured

set -e

echo "CIS 6.1.1 - Configuring /etc/passwd permissions..."

chmod u-x,go-wx /etc/passwd
chown root:root /etc/passwd

echo "Verifying permissions:"
stat -c "%n %a %U:%G" /etc/passwd

echo "CIS 6.1.1 remediation complete."