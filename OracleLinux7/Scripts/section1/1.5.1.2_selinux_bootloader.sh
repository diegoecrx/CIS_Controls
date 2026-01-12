#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.2 Ensure SELinux is not disabled in bootloader configuration
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.2 - Ensure SELinux is not disabled in bootloader ==="

# Remove selinux=0 and enforcing=0 from kernel parameters
grubby --update-kernel ALL --remove-args "selinux=0 enforcing=0"
echo " - Removed selinux=0 and enforcing=0 from kernel parameters"

# Also update /etc/default/grub if present
if [ -f /etc/default/grub ]; then
    sed -ri 's/\s*(selinux|enforcing)=0\s*//g' /etc/default/grub
    echo " - Updated /etc/default/grub"
fi

echo " - SELinux bootloader configuration complete"
echo "NOTE: Files created while SELinux is disabled are not labeled."
echo "A filesystem relabel may occur on next boot."
