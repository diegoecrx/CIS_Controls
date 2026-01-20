#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.3
# Ensure permissions on /etc/cron.hourly are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.3 - Setting permissions on /etc/cron.hourly..."

chown root:root /etc/cron.hourly/
chmod og-rwx /etc/cron.hourly/

echo "Verifying permissions:"
ls -ld /etc/cron.hourly/

echo "CIS 4.1.1.3 remediation complete."