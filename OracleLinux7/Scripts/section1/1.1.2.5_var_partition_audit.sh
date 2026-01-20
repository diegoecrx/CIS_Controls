#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

# CIS 1.1.2.5 - Ensure separate partition exists for /var (Compensating Control)
#
# NOTE: Creating a separate partition on OCI requires block volumes
# This script documents the current state - actual remediation requires
# OCI Block Volume attachment which must be done via OCI Console/CLI
#
# SAFE: This is an audit/documentation script only

echo "=== /var Partition Status ==="
echo ""

# Check current mount
VAR_MOUNT=$(df /var --output=source | tail -1)
ROOT_MOUNT=$(df / --output=source | tail -1)

if [ "$VAR_MOUNT" != "$ROOT_MOUNT" ]; then
    echo "[PASS] /var is on a separate partition: $VAR_MOUNT"
else
    echo "[INFO] /var is on root partition: $VAR_MOUNT"
    echo ""
    echo "=== Current /var usage ==="
    du -sh /var 2>/dev/null
    echo ""
    echo "=== Compensating Controls Available ==="
    echo "1. /var is protected by root filesystem permissions"
    echo "2. Disk quotas can be implemented to prevent /var from filling root"
    echo "3. Log rotation is configured to manage /var/log growth"
    echo ""
    echo "=== To implement separate /var partition on OCI ==="
    echo "1. Create Block Volume in OCI Console (recommended: 100GB)"
    echo "2. Attach to instance as iSCSI or paravirtualized"
    echo "3. Format with XFS: mkfs.xfs /dev/sdb"
    echo "4. Mount temporarily, rsync data, update fstab"
    echo "5. This requires a maintenance window"
fi

# Check logrotate status as compensating control
echo ""
echo "=== Log Rotation Status (Compensating Control) ==="
if [ -f /etc/logrotate.conf ]; then
    echo "[OK] logrotate is configured"
    grep -E "^rotate|^weekly|^monthly" /etc/logrotate.conf | head -5
else
    echo "[WARN] logrotate not found"
fi
