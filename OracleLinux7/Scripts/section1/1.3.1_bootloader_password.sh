#!/bin/bash
# CIS Oracle Linux 7 - 1.3.1 Ensure bootloader password is set
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: This may affect remote access/console recovery - DO NOT APPLY AUTOMATICALLY

echo "=== CIS 1.3.1 - Ensure bootloader password is set ==="
echo ""
echo "*** WARNING: This script will NOT automatically apply changes ***"
echo "*** Setting a bootloader password may affect remote recovery ***"
echo ""
echo "To set a bootloader password manually, run:"
echo "  grub2-setpassword"
echo ""
echo "Then enter and confirm your password when prompted."
echo ""
echo "Current status:"
if [ -f /boot/grub2/user.cfg ]; then
    if grep -q "GRUB2_PASSWORD" /boot/grub2/user.cfg; then
        echo "PASS: Bootloader password is set"
    else
        echo "FAIL: Bootloader password is NOT set"
    fi
else
    echo "FAIL: Bootloader password is NOT set (/boot/grub2/user.cfg not found)"
fi
