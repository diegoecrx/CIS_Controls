#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.3.1 Ensure bootloader password is set
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.3.1 - Ensure bootloader password is set ==="

# Check current status
if [ -f /boot/grub2/user.cfg ] && grep -q "GRUB2_PASSWORD" /boot/grub2/user.cfg; then
    echo "PASS: Bootloader password is already set"
    exit 0
fi

echo "Setting bootloader password..."

# Password: @NessusAudit#2014_
PASSWORD="@NessusAudit#2014_"

# Generate the password hash using grub2-mkpasswd-pbkdf2
HASH=$(echo -e "$PASSWORD\n$PASSWORD" | grub2-mkpasswd-pbkdf2 2>/dev/null | grep -o 'grub.pbkdf2.sha512.*')

if [ -z "$HASH" ]; then
    echo "FAIL: Unable to generate password hash"
    exit 1
fi

# Write directly to user.cfg
echo "GRUB2_PASSWORD=$HASH" > /boot/grub2/user.cfg

# Verify
if [ -f /boot/grub2/user.cfg ] && grep -q "GRUB2_PASSWORD" /boot/grub2/user.cfg; then
    echo "PASS: Bootloader password has been set successfully"
else
    echo "FAIL: Unable to set bootloader password"
    exit 1
fi

echo ""
echo "CIS 1.3.1 remediation complete."