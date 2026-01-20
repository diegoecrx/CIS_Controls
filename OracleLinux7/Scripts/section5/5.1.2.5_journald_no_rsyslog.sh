#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.5
# Ensure journald is not configured to send logs to rsyslog
# NOTE: This conflicts with 5.1.1.3 - choose based on your logging architecture

echo "CIS 5.1.2.5 - Checking journald rsyslog forwarding..."
echo "==========================================="
echo ""
echo "[WARNING] This control conflicts with 5.1.1.3"
echo "Choose based on your logging architecture:"
echo "  - If using rsyslog: keep ForwardToSyslog=yes (5.1.1.3)"
echo "  - If using only journald: remove ForwardToSyslog (5.1.2.5)"
echo ""
echo "Current setting:"
grep -E "^ForwardToSyslog|^#ForwardToSyslog" /etc/systemd/journald.conf 2>/dev/null || echo "Not configured"
echo ""
echo "To disable forwarding, remove or comment ForwardToSyslog in /etc/systemd/journald.conf"
echo "Then run: systemctl reload-or-try-restart systemd-journald.service"
echo ""
echo "CIS 5.1.2.5 - Manual review required."