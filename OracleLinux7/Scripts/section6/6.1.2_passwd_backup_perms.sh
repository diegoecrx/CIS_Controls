#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.2
# Ensure permissions on /etc/passwd- are configured

set -e

echo "CIS 6.1.2 - Configuring /etc/passwd- permissions..."

if [ -f /etc/passwd- ]; then
    chmod u-x,go-wx /etc/passwd-
    chown root:root /etc/passwd-
    echo "Verifying permissions:"
    stat -c "%n %a %U:%G" /etc/passwd-
else
    echo "/etc/passwd- does not exist"
fi

echo "CIS 6.1.2 remediation complete."