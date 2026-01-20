#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.14 - Ensure separate partition exists for /var/log/audit (Compensating Control)
# CIS 1.1.2.14.1 - Ensure nodev option set on /var/log/audit
# CIS 1.1.2.14.2 - Ensure nosuid option set on /var/log/audit
# CIS 1.1.2.14.3 - Ensure noexec option set on /var/log/audit
#
# SAFE: Uses bind mount to apply security options without partition changes

echo "=== Configuring /var/log/audit with secure mount options ==="

# Check if /var/log/audit bind mount entry exists in fstab
if grep -qE "^/var/log/audit.*/var/log/audit.*bind" /etc/fstab; then
    echo "[INFO] /var/log/audit bind mount entry exists in fstab"
else
    echo "[FIX] Adding /var/log/audit bind mount to fstab..."
    # Remove any old entries
    sed -i '/^\/var\/log\/audit.*bind/d' /etc/fstab
    sed -i '/CIS.*var.log.audit/d' /etc/fstab
    
    # Add bind mount entry with correct format
    echo "# CIS 1.1.2.14 - /var/log/audit bind mount with noexec,nosuid,nodev" >> /etc/fstab
    echo "/var/log/audit /var/log/audit none rw,bind,noexec,nosuid,nodev 0 0" >> /etc/fstab
    echo "[OK] Added /var/log/audit bind mount to /etc/fstab"
fi

# Ensure /var/log/audit exists
mkdir -p /var/log/audit

# Apply the bind mount now
echo "[INFO] Applying bind mount with secure options..."
mount --bind /var/log/audit /var/log/audit 2>/dev/null
mount -o remount,bind,nosuid,nodev,noexec /var/log/audit

# Verify
echo ""
echo "=== Verification ==="
findmnt -n /var/log/audit

echo "[DONE] /var/log/audit configured"
