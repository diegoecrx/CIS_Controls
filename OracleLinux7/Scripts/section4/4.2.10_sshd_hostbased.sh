#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.2.10
# Ensure sshd HostbasedAuthentication is disabled
# This script disables host-based authentication

set -e

echo "CIS 4.2.10 - Configuring sshd HostbasedAuthentication..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure HostbasedAuthentication
if grep -Eq '^\s*HostbasedAuthentication\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*HostbasedAuthentication\s.*|HostbasedAuthentication no|' /etc/ssh/sshd_config
else
    echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^HostbasedAuthentication" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.10 remediation complete."