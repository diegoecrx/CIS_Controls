#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.4
# Ensure permissions on /etc/cron.daily are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.4 - Setting permissions on /etc/cron.daily..."

chown root:root /etc/cron.daily/
chmod og-rwx /etc/cron.daily/

echo "Verifying permissions:"
ls -ld /etc/cron.daily/

echo "CIS 4.1.1.4 remediation complete."