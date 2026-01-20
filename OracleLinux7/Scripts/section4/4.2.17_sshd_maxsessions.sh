#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.2.17
# Ensure sshd MaxSessions is configured
# This script configures MaxSessions

set -e

echo "CIS 4.2.17 - Configuring sshd MaxSessions..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure MaxSessions
if grep -Eq '^\s*MaxSessions\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*MaxSessions\s.*|MaxSessions 10|' /etc/ssh/sshd_config
else
    echo "MaxSessions 10" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^MaxSessions" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.17 remediation complete."