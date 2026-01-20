#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.2.1
# Ensure permissions on /etc/ssh/sshd_config are configured
# This script sets proper ownership and permissions on SSH config files

set -e

echo "CIS 4.2.1 - Setting permissions on SSH configuration files..."

# Set permissions on main sshd_config
chmod u-x,og-rwx /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config

# Set permissions on files in sshd_config.d
if [ -d /etc/ssh/sshd_config.d ]; then
    while IFS= read -r -d $'\0' l_file; do
        if [ -e "$l_file" ]; then
            chmod u-x,og-rwx "$l_file"
            chown root:root "$l_file"
        fi
    done < <(find /etc/ssh/sshd_config.d -type f -print0)
fi

echo "Verifying permissions:"
ls -l /etc/ssh/sshd_config
ls -la /etc/ssh/sshd_config.d/ 2>/dev/null || true

echo "CIS 4.2.1 remediation complete."