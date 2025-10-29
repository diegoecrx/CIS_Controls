#!/bin/bash

SCRIPT_NAME="1.1.19_removable_partitions_noexec.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    local level="$1"
    shift
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$level] [$SCRIPT_NAME] $@" | tee -a "$LOG_FILE"
}

backup_file() {
    local file="$1"
    [ -f "$file" ] || return 1
    cp "$file" "$BACKUP_DIR/$(basename $file).$(date +%Y%m%d_%H%M%S).backup" 2>/dev/null
}

# FIXED: Proper device detection without logging interference
detect_removable_devices() {
    local devices=""
    
    # Check for removable block devices that are mounted
    for dev in /sys/block/*/removable; do
        [ -f "$dev" ] || continue
        [ "$(cat $dev 2>/dev/null)" = "1" ] || continue
        
        local blockdev=$(echo $dev | cut -d/ -f4)
        
        # Check if device or its partitions are mounted
        if mount | grep -q "^/dev/${blockdev}"; then
            for partition in /dev/${blockdev}*; do
                if mount | grep -q "^${partition} "; then
                    devices="$devices $partition"
                fi
            done
        fi
    done
    
    # Check for optical drives
    for cdrom in /dev/sr[0-9]* /dev/cdrom; do
        [ -b "$cdrom" ] || continue
        if mount | grep -q "^${cdrom} "; then
            devices="$devices $cdrom"
        fi
    done
    
    echo "$devices" | xargs
}

create_udev_rule() {
    cat > /etc/udev/rules.d/99-removable-noexec.rules << 'EOF'
# CIS 1.1.19 - Removable media security
ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="noexec,nodev,nosuid"
ACTION=="add", SUBSYSTEM=="block", ENV{ID_CDROM}=="1", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="ro,noexec,nodev,nosuid"
EOF
    
    udevadm control --reload-rules 2>/dev/null
    log_message "SUCCESS" "Created and loaded udev rules"
}

configure_systemd_automount() {
    mkdir -p /etc/systemd/system/media.mount.d
    
    cat > /etc/systemd/system/media.mount.d/options.conf << 'EOF'
[Mount]
Options=noexec,nodev,nosuid
EOF
    
    systemctl daemon-reload 2>/dev/null
    log_message "SUCCESS" "Configured systemd automount"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    # Detect removable devices (properly this time)
    local removable_devices=$(detect_removable_devices)
    local device_count=$(echo "$removable_devices" | wc -w)
    
    if [ $device_count -eq 0 ]; then
        log_message "INFO" "No removable media currently mounted"
        echo ""
        echo "No removable media detected."
        echo "Applying preventive configuration..."
        echo ""
    else
        log_message "INFO" "Found $device_count removable device(s)"
        echo ""
        echo "Removable devices found: $device_count"
        echo ""
        
        for device in $removable_devices; do
            echo "Device: $device"
            if mount | grep "^$device " | grep -q "noexec"; then
                echo "  Status: COMPLIANT"
                log_message "SUCCESS" "$device has noexec"
            else
                echo "  Status: NON-COMPLIANT (missing noexec)"
                log_message "WARNING" "$device missing noexec"
            fi
            echo ""
        done
    fi
    
    # Apply preventive configuration
    create_udev_rule
    configure_systemd_automount
    
    echo ""
    echo "========================================"
    echo "Configuration Complete"
    echo "========================================"
    echo ""
    echo "Preventive measures applied:"
    echo "  - udev rules for USB/CD/DVD"
    echo "  - systemd automount security"
    echo ""
    echo "Future removable media will mount with:"
    echo "  noexec, nodev, nosuid"
    echo ""
    
    log_message "SUCCESS" "Remediation completed"
}

if [ "$EUID" -ne 0 ]; then
    echo "Error: Must run as root"
    exit 1
fi

main_remediation
