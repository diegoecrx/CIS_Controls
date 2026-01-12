#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.1.1.2
# Ensure permissions on /etc/crontab are configured
# This script sets proper ownership and permissions

set -e

echo "CIS 4.1.1.2 - Setting permissions on /etc/crontab..."

chown root:root /etc/crontab
chmod og-rwx /etc/crontab

echo "Verifying permissions:"
ls -l /etc/crontab

echo "CIS 4.1.1.2 remediation complete."