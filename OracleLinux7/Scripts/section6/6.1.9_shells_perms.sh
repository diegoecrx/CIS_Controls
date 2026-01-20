#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.9
# Ensure permissions on /etc/shells are configured

set -e

echo "CIS 6.1.9 - Configuring /etc/shells permissions..."

chmod u-x,go-wx /etc/shells
chown root:root /etc/shells

echo "Verifying permissions:"
stat -c "%n %a %U:%G" /etc/shells

echo "CIS 6.1.9 remediation complete."