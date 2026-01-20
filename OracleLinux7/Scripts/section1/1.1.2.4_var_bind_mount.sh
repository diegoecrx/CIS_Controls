#!/bin/bash
# CIS 1.1.2.4 - Ensure /var has nosuid and nodev options
# This script sets up a bind mount for /var with security options

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Check if already configured in fstab
if ! grep -q '^/var /var none' /etc/fstab; then
    echo "# CIS 1.1.2.4 - /var bind mount with nosuid,nodev" >> /etc/fstab
    echo "/var /var none rw,bind,nosuid,nodev 0 0" >> /etc/fstab
    echo "Added /var bind mount entry to /etc/fstab"
fi

# Apply the mount if not already mounted as bind
if ! mount | grep -q "on /var type.*bind"; then
    mount --bind /var /var
fi

# Apply security options
mount -o remount,nosuid,nodev /var

# Verify
echo "=== /var mount options ==="
findmnt -rn /var
