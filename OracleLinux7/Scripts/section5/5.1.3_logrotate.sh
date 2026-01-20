#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.3
# Ensure logrotate is configured

set -e

echo "CIS 5.1.3 - Configuring logrotate..."

# Backup existing configuration
cp /etc/logrotate.conf /etc/logrotate.conf.bak.$(date +%Y%m%d%H%M%S)

# Fix wtmp permissions to be 640 instead of 664 (CIS requirement)
sed -i 's/create 0664 root utmp/create 0640 root utmp/' /etc/logrotate.conf

echo "Current logrotate.conf settings:"
cat /etc/logrotate.conf

echo ""
echo "Logrotate.d configurations:"
ls /etc/logrotate.d/

echo ""
echo "CIS 5.1.3 remediation complete - wtmp create permissions fixed to 0640."
