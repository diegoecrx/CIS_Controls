#!/bin/bash
# CIS Oracle Linux 7 - 1.3.2 Ensure permissions on bootloader config are configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.3.2 - Configure bootloader config permissions ==="

# Check if system uses UEFI or BIOS
if [ -d /sys/firmware/efi ]; then
    echo " - System uses UEFI boot"
    echo " - For UEFI, edit /etc/fstab and add fmask=0077,uid=0,gid=0 to /boot/efi mount options"
    echo " - This may require a reboot"
else
    echo " - System uses BIOS boot"
    
    # Set permissions on GRUB2 configuration files
    if [ -f /boot/grub2/grub.cfg ]; then
        chown root:root /boot/grub2/grub.cfg
        chmod u-x,go-rwx /boot/grub2/grub.cfg
        echo " - Set permissions on /boot/grub2/grub.cfg"
    fi
    
    if [ -f /boot/grub2/grubenv ]; then
        chown root:root /boot/grub2/grubenv
        chmod u-x,go-rwx /boot/grub2/grubenv
        echo " - Set permissions on /boot/grub2/grubenv"
    fi
    
    if [ -f /boot/grub2/user.cfg ]; then
        chown root:root /boot/grub2/user.cfg
        chmod u-x,go-rwx /boot/grub2/user.cfg
        echo " - Set permissions on /boot/grub2/user.cfg"
    fi
fi

echo " - Bootloader config permissions complete"
