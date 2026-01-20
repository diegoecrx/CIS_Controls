#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.10
# Ensure permissions on /etc/security/opasswd are configured

set -e

echo "CIS 6.1.10 - Configuring /etc/security/opasswd permissions..."

if [ -e "/etc/security/opasswd" ]; then
    chmod u-x,go-rwx /etc/security/opasswd
    chown root:root /etc/security/opasswd
    echo "Configured /etc/security/opasswd:"
    stat -c "%n %a %U:%G" /etc/security/opasswd
else
    echo "/etc/security/opasswd does not exist"
fi

if [ -e "/etc/security/opasswd.old" ]; then
    chmod u-x,go-rwx /etc/security/opasswd.old
    chown root:root /etc/security/opasswd.old
    echo "Configured /etc/security/opasswd.old:"
    stat -c "%n %a %U:%G" /etc/security/opasswd.old
else
    echo "/etc/security/opasswd.old does not exist"
fi

echo "CIS 6.1.10 remediation complete."