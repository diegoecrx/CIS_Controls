#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.1 - Ensure /tmp is a separate partition (Compensating Control)
# CIS 1.1.2.1.1 - Ensure nodev option set on /tmp
# CIS 1.1.2.1.2 - Ensure nosuid option set on /tmp
# CIS 1.1.2.1.3 - Ensure noexec option set on /tmp
#
# Uses tmpfs for /tmp which provides all required security options

echo "=== Configuring /tmp with secure mount options ==="

# Check if /tmp tmpfs entry exists in fstab
if grep -qE "^tmpfs\s+/tmp" /etc/fstab; then
    echo "[INFO] /tmp tmpfs entry exists in fstab"
    # Update existing entry with correct options
    sed -i 's|^tmpfs\s\+/tmp.*|tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0|' /etc/fstab
else
    echo "[FIX] Adding /tmp tmpfs to fstab..."
    echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    echo "[OK] Added /tmp tmpfs to /etc/fstab"
fi

# Apply mount now
echo "[INFO] Remounting /tmp with secure options..."
mount -o remount,nosuid,nodev,noexec /tmp 2>/dev/null || mount -t tmpfs -o nosuid,nodev,noexec tmpfs /tmp

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /tmp

echo "[DONE] /tmp configured"
