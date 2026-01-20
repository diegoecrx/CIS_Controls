#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.1
# Ensure cron daemon is enabled and active
# This script enables and starts crond

set -e

echo "CIS 4.1.1.1 - Enabling cron daemon..."

# Unmask crond if masked
systemctl unmask crond 2>/dev/null || true

# Enable and start crond
systemctl --now enable crond

echo "Verifying crond status:"
systemctl is-enabled crond
systemctl is-active crond

echo "CIS 4.1.1.1 remediation complete."