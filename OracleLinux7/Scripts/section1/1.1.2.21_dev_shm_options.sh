#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.2 - Ensure /dev/shm is configured
# CIS 1.1.2.2.1 - Ensure nodev option set on /dev/shm
# CIS 1.1.2.2.2 - Ensure nosuid option set on /dev/shm
# CIS 1.1.2.2.3 - Ensure noexec option set on /dev/shm
#
# Configures tmpfs for /dev/shm with security options

echo "=== Configuring /dev/shm with secure mount options ==="

# Check if /dev/shm tmpfs entry exists in fstab
if grep -qE "^tmpfs\s+/dev/shm" /etc/fstab; then
    echo "[INFO] /dev/shm tmpfs entry exists in fstab"
    # Update existing entry with correct options
    sed -i 's|^tmpfs\s\+/dev/shm.*|tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime,size=2G 0 0|' /etc/fstab
else
    echo "[FIX] Adding /dev/shm tmpfs to fstab..."
    echo "tmpfs /dev/shm tmpfs defaults,rw,nosuid,nodev,noexec,relatime,size=2G 0 0" >> /etc/fstab
    echo "[OK] Added /dev/shm tmpfs to /etc/fstab"
fi

# Apply mount now
echo "[INFO] Remounting /dev/shm with secure options..."
mount -o remount,nosuid,nodev,noexec /dev/shm

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /dev/shm

echo "[DONE] /dev/shm configured"
