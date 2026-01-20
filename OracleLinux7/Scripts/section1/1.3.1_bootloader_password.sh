#!/bin/bash
# CIS Oracle Linux 7 - 1.3.1 Ensure bootloader password is set
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.3.1 - Ensure bootloader password is set ==="

# Check current status
if [ -f /boot/grub2/user.cfg ] && grep -q "GRUB2_PASSWORD" /boot/grub2/user.cfg; then
    echo "PASS: Bootloader password is already set"
    exit 0
fi

echo "Setting bootloader password..."

# Set the password using grub2-setpassword with expect-style input
# Password: @NessusAudit#2014_
echo -e "@NessusAudit#2014_\n@NessusAudit#2014_" | grub2-setpassword

# Verify
if [ -f /boot/grub2/user.cfg ] && grep -q "GRUB2_PASSWORD" /boot/grub2/user.cfg; then
    echo "PASS: Bootloader password has been set successfully"
else
    echo "FAIL: Unable to set bootloader password"
    exit 1
fi

echo ""
echo "CIS 1.3.1 remediation complete."
