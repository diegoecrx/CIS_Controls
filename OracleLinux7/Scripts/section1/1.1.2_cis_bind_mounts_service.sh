#!/bin/bash
# CIS Benchmark - Ensure bind mount security options persist
# This script creates a systemd service that applies correct mount options at boot
# Works with OCI Oracle Linux 7 where /home, /var, /var/tmp, /var/log are on root partition

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

echo "CIS 1.1.2 - Creating bind mount service for partition security..."

# Create the helper script
cat > /usr/local/bin/cis-bind-mounts.sh << 'ENDSCRIPT'
#!/bin/bash
# CIS Benchmark - Apply mount options using bind mounts
# For directories on root partition that need different options

sleep 3

# Function to create bind mount with options if not already done
apply_bind_mount() {
    local mnt=$1
    local opts=$2
    
    # Check if already a bind mount (has [/...] in findmnt output)
    if findmnt -n "$mnt" 2>/dev/null | grep -q '\[/'; then
        # Already bound, just remount with options
        mount -o remount,$opts "$mnt" 2>/dev/null
    else
        # Not bound yet, create bind mount
        mount --bind "$mnt" "$mnt"
        mount -o remount,$opts "$mnt"
    fi
}

apply_bind_mount /home nosuid,nodev
apply_bind_mount /var nosuid,nodev
apply_bind_mount /var/tmp nosuid,nodev,noexec
apply_bind_mount /var/log nosuid,nodev,noexec
apply_bind_mount /var/log/audit nosuid,nodev,noexec

exit 0
ENDSCRIPT

chmod 755 /usr/local/bin/cis-bind-mounts.sh

# Create systemd service
cat > /etc/systemd/system/cis-bind-mounts.service << 'ENDSERVICE'
[Unit]
Description=CIS Benchmark Apply Mount Options
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cis-bind-mounts.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
ENDSERVICE

# Enable and start service
systemctl daemon-reload
systemctl enable cis-bind-mounts.service
systemctl start cis-bind-mounts.service

echo "CIS bind mount service created and enabled"
systemctl status cis-bind-mounts.service --no-pager

echo ""
echo "Verifying mount options:"
for mp in /home /var /var/tmp /var/log /var/log/audit; do
    echo "$mp: $(findmnt -n $mp -o OPTIONS | head -1)"
done
