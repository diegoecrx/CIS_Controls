#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.1.4
# Ensure permissions on /etc/group- are configured

set -e

echo "CIS 6.1.4 - Configuring /etc/group- permissions..."

if [ -f /etc/group- ]; then
    chmod u-x,go-wx /etc/group-
    chown root:root /etc/group-
    echo "Verifying permissions:"
    stat -c "%n %a %U:%G" /etc/group-
else
    echo "/etc/group- does not exist (no backup file created yet)"
fi

echo "CIS 6.1.4 remediation complete."