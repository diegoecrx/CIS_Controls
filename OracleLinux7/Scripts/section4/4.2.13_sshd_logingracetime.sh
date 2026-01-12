#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.13
# Ensure sshd LoginGraceTime is configured
# This script configures LoginGraceTime

set -e

echo "CIS 4.2.13 - Configuring sshd LoginGraceTime..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure LoginGraceTime
if grep -Eq '^\s*LoginGraceTime\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*LoginGraceTime\s.*|LoginGraceTime 60|' /etc/ssh/sshd_config
else
    echo "LoginGraceTime 60" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^LoginGraceTime" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.13 remediation complete."