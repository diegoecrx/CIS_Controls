#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.1.6
# Ensure permissions on /etc/shadow- are configured

set -e

echo "CIS 6.1.6 - Configuring /etc/shadow- permissions..."

if [ -f /etc/shadow- ]; then
    chmod 0000 /etc/shadow-
    chown root:root /etc/shadow-
    echo "Verifying permissions:"
    stat -c "%n %a %U:%G" /etc/shadow-
else
    echo "/etc/shadow- does not exist (no backup file created yet)"
fi

echo "CIS 6.1.6 remediation complete."