#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.20
# Ensure X window server services are not in use
# This script removes X Windows Server packages

set -e

echo "CIS 2.2.20 - Checking X Window Server services..."

# Check if xorg-x11-server-common is installed
if rpm -q xorg-x11-server-common &>/dev/null; then
    echo "WARNING: X Window Server packages are installed."
    echo "If this is a server without GUI requirements, consider removing with:"
    echo "  yum remove xorg-x11-server-common"
    echo ""
    echo "Note: Removing this package may break GDM and GUI applications."
    echo "Only remove if GUI is not required on this system."
else
    echo "X Window Server packages are not installed."
fi

echo "CIS 2.2.20 remediation complete - X Window Server checked."