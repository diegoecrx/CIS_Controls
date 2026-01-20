#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.1.6
# Ensure rsyslog is configured to send logs to a remote log host
# This script provides PRINT ONLY (environment specific)

echo "CIS 5.1.1.6 - Remote logging configuration..."
echo "==========================================="
echo ""
echo "[INFO] This control requires site-specific configuration."
echo ""
echo "To configure remote logging, add the following to /etc/rsyslog.conf:"
echo ""
echo '*.* action(type="omfwd" target="<REMOTE_LOG_HOST>" port="514" protocol="tcp"'
echo '           action.resumeRetryCount="100"'
echo '           queue.type="LinkedList" queue.size="1000")'
echo ""
echo "Replace <REMOTE_LOG_HOST> with your log server IP or FQDN."
echo ""
echo "After changes, run: systemctl restart rsyslog"
echo ""
echo "CIS 5.1.1.6 - Manual configuration required."