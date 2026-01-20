#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.3
# Ensure permissions on /etc/group are configured

set -e

echo "CIS 6.1.3 - Configuring /etc/group permissions..."

chmod u-x,go-wx /etc/group
chown root:root /etc/group

echo "Verifying permissions:"
stat -c "%n %a %U:%G" /etc/group

echo "CIS 6.1.3 remediation complete."