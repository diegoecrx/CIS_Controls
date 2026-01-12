#!/bin/bash
# CIS Oracle Linux 7 - 1.3.3 Ensure authentication required for single user mode
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: This affects system recovery - DO NOT APPLY AUTOMATICALLY

echo "=== CIS 1.3.3 - Ensure authentication required for single user mode ==="
echo ""
echo "*** WARNING: This script will NOT automatically apply changes ***"
echo "*** Modifying single user mode may affect system recovery ***"
echo ""
echo "To configure manually, edit the following files:"
echo "  /usr/lib/systemd/system/rescue.service"
echo "  /usr/lib/systemd/system/emergency.service"
echo ""
echo "Set ExecStart to:"
echo '  ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
echo ""
echo "Current rescue.service ExecStart:"
grep -i "^ExecStart" /usr/lib/systemd/system/rescue.service 2>/dev/null || echo "Not found"
echo ""
echo "Current emergency.service ExecStart:"
grep -i "^ExecStart" /usr/lib/systemd/system/emergency.service 2>/dev/null || echo "Not found"
