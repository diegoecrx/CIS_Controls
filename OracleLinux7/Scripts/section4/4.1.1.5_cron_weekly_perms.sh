#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.5
# Ensure permissions on /etc/cron.weekly are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.5 - Setting permissions on /etc/cron.weekly..."

chown root:root /etc/cron.weekly/
chmod og-rwx /etc/cron.weekly/

echo "Verifying permissions:"
ls -ld /etc/cron.weekly/

echo "CIS 4.1.1.5 remediation complete."