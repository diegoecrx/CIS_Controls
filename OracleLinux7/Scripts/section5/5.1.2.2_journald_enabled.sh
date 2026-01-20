#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.2
# Ensure journald service is enabled
# This script provides audit check only

echo "CIS 5.1.2.2 - Checking journald service status..."

echo "systemd-journald status:"
systemctl status systemd-journald.service --no-pager | head -10

echo ""
echo "NOTE: systemd-journald does not have an [Install] section."
echo "It should show 'static' status and be active."

echo ""
echo "CIS 5.1.2.2 - Audit complete."