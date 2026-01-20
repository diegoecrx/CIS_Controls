#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.7
# Ensure permissions on /etc/gshadow are configured

set -e

echo "CIS 6.1.7 - Configuring /etc/gshadow permissions..."

chmod 0000 /etc/gshadow
chown root:root /etc/gshadow

echo "Verifying permissions:"
stat -c "%n %a %U:%G" /etc/gshadow

echo "CIS 6.1.7 remediation complete."