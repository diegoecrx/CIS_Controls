#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.18 - Ensure separate partition exists for /home (Compensating Control)
# CIS 1.1.2.18.1 - Ensure nodev option set on /home
# CIS 1.1.2.18.2 - Ensure nosuid option set on /home
#
# SAFE: Uses bind mount to apply security options without partition changes
# NOTE: /home does NOT get noexec to allow users to run scripts

echo "=== Configuring /home with secure mount options ==="

# Check if /home bind mount entry exists in fstab
if grep -qE "^/home.*/home.*bind" /etc/fstab; then
    echo "[INFO] /home bind mount entry exists in fstab"
else
    echo "[FIX] Adding /home bind mount to fstab..."
    # Remove any old entries
    sed -i '/^\/home.*bind/d' /etc/fstab
    sed -i '/CIS.*home/d' /etc/fstab
    
    # Add bind mount entry with correct format (no noexec for home)
    echo "# CIS 1.1.2.18 - /home bind mount with nosuid,nodev" >> /etc/fstab
    echo "/home /home none rw,bind,nosuid,nodev 0 0" >> /etc/fstab
    echo "[OK] Added /home bind mount to /etc/fstab"
fi

# Ensure /home exists
mkdir -p /home

# Apply the bind mount now
echo "[INFO] Applying bind mount with secure options..."
mount --bind /home /home 2>/dev/null
mount -o remount,bind,nosuid,nodev /home

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /home

echo "[DONE] /home configured"
