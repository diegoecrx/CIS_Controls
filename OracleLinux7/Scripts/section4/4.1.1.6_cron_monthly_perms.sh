#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.1.1.6
# Ensure permissions on /etc/cron.monthly are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.6 - Setting permissions on /etc/cron.monthly..."

chown root:root /etc/cron.monthly/
chmod og-rwx /etc/cron.monthly/

echo "Verifying permissions:"
ls -ld /etc/cron.monthly/

echo "CIS 4.1.1.6 remediation complete."