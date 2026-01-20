#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.7
# Ensure permissions on /etc/cron.d are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.7 - Setting permissions on /etc/cron.d..."

chown root:root /etc/cron.d/
chmod og-rwx /etc/cron.d/

echo "Verifying permissions:"
ls -ld /etc/cron.d/

echo "CIS 4.1.1.7 remediation complete."