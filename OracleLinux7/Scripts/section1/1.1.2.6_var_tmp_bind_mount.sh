#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.6 - Ensure separate partition exists for /var/tmp (Compensating Control)
# CIS 1.1.2.6.1 - Ensure nodev option set on /var/tmp
# CIS 1.1.2.6.2 - Ensure nosuid option set on /var/tmp
# CIS 1.1.2.6.3 - Ensure noexec option set on /var/tmp
#
# SAFE: Uses bind mount to apply security options without partition changes

echo "=== Configuring /var/tmp with secure mount options ==="

# Check if /var/tmp bind mount entry exists in fstab
if grep -qE "^/var/tmp.*/var/tmp.*bind" /etc/fstab; then
    echo "[INFO] /var/tmp bind mount entry exists in fstab"
else
    echo "[FIX] Adding /var/tmp bind mount to fstab..."
    # Remove any old entries
    sed -i '/^\/var\/tmp.*bind/d' /etc/fstab
    sed -i '/CIS.*var.tmp/d' /etc/fstab
    
    # Add bind mount entry with correct format
    echo "# CIS 1.1.2.6 - /var/tmp bind mount with noexec,nosuid,nodev" >> /etc/fstab
    echo "/var/tmp /var/tmp none rw,bind,noexec,nosuid,nodev 0 0" >> /etc/fstab
    echo "[OK] Added /var/tmp bind mount to /etc/fstab"
fi

# Ensure /var/tmp exists with correct permissions
mkdir -p /var/tmp
chmod 1777 /var/tmp

# Apply the bind mount now
echo "[INFO] Applying bind mount with secure options..."
mount --bind /var/tmp /var/tmp 2>/dev/null
mount -o remount,bind,nosuid,nodev,noexec /var/tmp

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /var/tmp

echo "[DONE] /var/tmp configured"
