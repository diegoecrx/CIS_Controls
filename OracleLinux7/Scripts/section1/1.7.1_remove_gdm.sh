#!/bin/bash
# CIS Oracle Linux 7 - 1.7.1 Ensure GNOME Display Manager is removed
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: This will remove the GUI - DO NOT APPLY on systems requiring GUI

echo "=== CIS 1.7.1 - Remove GNOME Display Manager ==="
echo ""
echo "*** WARNING: This script will NOT automatically remove GDM ***"
echo "*** Removing gdm will remove the graphical user interface ***"
echo ""
echo "Current status:"
if rpm -q gdm > /dev/null 2>&1; then
    echo "GDM is installed"
    echo ""
    echo "To remove GDM manually, run:"
    echo "  yum remove gdm"
else
    echo "GDM is not installed (PASS)"
fi
