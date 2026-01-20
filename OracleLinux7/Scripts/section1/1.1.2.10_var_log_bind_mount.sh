#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.10 - Ensure separate partition exists for /var/log (Compensating Control)
# CIS 1.1.2.10.1 - Ensure nodev option set on /var/log
# CIS 1.1.2.10.2 - Ensure nosuid option set on /var/log
# CIS 1.1.2.10.3 - Ensure noexec option set on /var/log
#
# SAFE: Uses bind mount to apply security options without partition changes

echo "=== Configuring /var/log with secure mount options ==="

# Check if /var/log bind mount entry exists in fstab
if grep -qE "^/var/log.*/var/log.*bind" /etc/fstab; then
    echo "[INFO] /var/log bind mount entry exists in fstab"
else
    echo "[FIX] Adding /var/log bind mount to fstab..."
    # Remove any old entries
    sed -i '/^\/var\/log[^\/].*bind/d' /etc/fstab
    sed -i '/CIS.*var.log[^\/]/d' /etc/fstab
    
    # Add bind mount entry with correct format
    echo "# CIS 1.1.2.10 - /var/log bind mount with noexec,nosuid,nodev" >> /etc/fstab
    echo "/var/log /var/log none rw,bind,noexec,nosuid,nodev 0 0" >> /etc/fstab
    echo "[OK] Added /var/log bind mount to /etc/fstab"
fi

# Ensure /var/log exists
mkdir -p /var/log

# Apply the bind mount now
echo "[INFO] Applying bind mount with secure options..."
mount --bind /var/log /var/log 2>/dev/null
mount -o remount,bind,nosuid,nodev,noexec /var/log

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /var/log

echo "[DONE] /var/log configured"
