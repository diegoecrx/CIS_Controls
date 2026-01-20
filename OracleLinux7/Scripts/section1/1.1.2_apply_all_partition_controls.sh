#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2 - Master script to apply ALL partition compensating controls
# 
# SAFE: This script uses bind mounts and tmpfs options
# NO partition changes are made - fully reversible
#
# What this does:
# 1. Ensures /tmp has nosuid,nodev,noexec (already tmpfs)
# 2. Ensures /dev/shm has nosuid,nodev,noexec (already tmpfs)
# 3. Creates bind mount for /var/tmp with nosuid,nodev,noexec
# 4. Creates bind mount for /var/log with nosuid,nodev,noexec
# 5. Creates bind mount for /var/log/audit with nosuid,nodev,noexec
# 6. Creates bind mount for /home with nosuid,nodev

echo "=============================================="
echo "CIS Partition Compensating Controls - Master"
echo "=============================================="
echo ""
echo "This script applies secure mount options without"
echo "requiring separate partitions. All changes are"
echo "reversible and do not modify disk structure."
echo ""
echo "Press Ctrl+C within 5 seconds to abort..."
sleep 5
echo ""
echo "Proceeding with configuration..."
echo ""

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Run each script
echo "=== Step 1: Configuring /tmp ==="
bash "$SCRIPT_DIR/1.1.2.1_tmp_mount_options.sh"
echo ""

echo "=== Step 2: Configuring /dev/shm ==="
bash "$SCRIPT_DIR/1.1.2.21_dev_shm_options.sh"
echo ""

echo "=== Step 3: Configuring /var/tmp ==="
bash "$SCRIPT_DIR/1.1.2.6_var_tmp_bind_mount.sh"
echo ""

echo "=== Step 4: Configuring /var/log ==="
bash "$SCRIPT_DIR/1.1.2.10_var_log_bind_mount.sh"
echo ""

echo "=== Step 5: Configuring /var/log/audit ==="
bash "$SCRIPT_DIR/1.1.2.14_var_log_audit_bind_mount.sh"
echo ""

echo "=== Step 6: Configuring /home ==="
bash "$SCRIPT_DIR/1.1.2.18_home_bind_mount.sh"
echo ""

echo "=============================================="
echo "SUMMARY"
echo "=============================================="
echo ""
echo "Mount points configured with security options:"
findmnt -t tmpfs 2>/dev/null
echo ""
echo "Bind mounts:"
mount | grep "bind" 2>/dev/null || echo "(Bind mounts may require reboot to show)"
echo ""
echo "=== /etc/fstab entries added ==="
grep -E "(nosuid|nodev|noexec)" /etc/fstab | grep -v "^#"
echo ""
echo "=============================================="
echo "NOTE: Some changes may require a reboot to"
echo "fully take effect. A reboot is RECOMMENDED"
echo "but not required for security to be active."
echo "=============================================="
