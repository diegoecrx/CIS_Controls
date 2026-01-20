#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.6
# Ensure journald log rotation is configured per site policy
# This script provides PRINT ONLY (site specific)

echo "CIS 5.1.2.6 - Checking journald log rotation..."
echo "==========================================="
echo ""
echo "Current journald rotation settings:"
grep -E "^SystemMaxUse|^SystemKeepFree|^RuntimeMaxUse|^RuntimeKeepFree|^MaxFileSec" /etc/systemd/journald.conf 2>/dev/null || echo "Using defaults"
echo ""
echo "Available rotation parameters (add to /etc/systemd/journald.conf):"
echo "  SystemMaxUse=       # Max disk space for persistent logs"
echo "  SystemKeepFree=     # Min free space to leave on disk"
echo "  RuntimeMaxUse=      # Max disk space for runtime logs"
echo "  RuntimeKeepFree=    # Min free space for runtime"
echo "  MaxFileSec=         # Max time to store entries in single file"
echo ""
echo "Example configuration:"
echo "  SystemMaxUse=500M"
echo "  SystemKeepFree=1G"
echo "  MaxFileSec=1month"
echo ""
echo "CIS 5.1.2.6 - Manual review required."