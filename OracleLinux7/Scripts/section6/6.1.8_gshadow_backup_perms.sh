#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.1.8
# Ensure permissions on /etc/gshadow- are configured

set -e

echo "CIS 6.1.8 - Configuring /etc/gshadow- permissions..."

if [ -f /etc/gshadow- ]; then
    chmod 0000 /etc/gshadow-
    chown root:root /etc/gshadow-
    echo "Verifying permissions:"
    stat -c "%n %a %U:%G" /etc/gshadow-
else
    echo "/etc/gshadow- does not exist (no backup file created yet)"
fi

echo "CIS 6.1.8 remediation complete."