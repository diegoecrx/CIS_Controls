#!/bin/bash

SCRIPT_NAME="1.1.21_nosuid_removable_partitions.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

detect_removable_devices() {
    local devices=""
    
    for dev in /sys/block/*/removable; do
        [ -f "$dev" ] || continue
        [ "$(cat $dev 2>/dev/null)" = "1" ] || continue
        
        local blockdev=$(echo $dev | cut -d/ -f4)
        
        if mount | grep -q "^/dev/${blockdev}"; then
            for partition in /dev/${blockdev}*; do
                if mount | grep -q "^${partition} "; then
                    devices="$devices $partition"
                fi
            done
        fi
    done
    
    for cdrom in /dev/sr[0-9]* /dev/cdrom; do
        [ -b "$cdrom" ] || continue
        if mount | grep -q "^${cdrom} "; then
            devices="$devices $cdrom"
        fi
    done
    
    echo "$devices" | xargs
}

create_udev_rule() {
    cat > /etc/udev/rules.d/99-removable-nosuid.rules << 'EOF'
# CIS 1.1.21 - Removable media nosuid
ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="noexec,nodev,nosuid"
ACTION=="add", SUBSYSTEM=="block", ENV{ID_CDROM}=="1", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="ro,noexec,nodev,nosuid"
EOF
    
    udevadm control --reload-rules 2>/dev/null
    log_message "SUCCESS" "Created udev rules for nosuid enforcement"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    local removable_devices=$(detect_removable_devices)
    local device_count=$(echo "$removable_devices" | wc -w)
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.21 - nosuid on Removable Media"
    echo "========================================"
    echo ""
    
    if [ $device_count -eq 0 ]; then
        log_message "INFO" "No removable media mounted"
        echo "No removable media currently mounted"
        echo "Applying preventive configuration..."
    else
        log_message "INFO" "Found $device_count removable device(s)"
        echo "Removable devices: $device_count"
        echo ""
        
        for device in $removable_devices; do
            echo "Device: $device"
            if mount | grep "^$device " | grep -q "nosuid"; then
                echo "  Status: COMPLIANT (has nosuid)"
                log_message "SUCCESS" "$device has nosuid"
            else
                echo "  Status: NON-COMPLIANT (missing nosuid)"
                log_message "WARNING" "$device missing nosuid"
            fi
        done
    fi
    
    create_udev_rule
    
    echo ""
    echo "Configuration complete"
    echo "Future removable media will have nosuid option"
    echo ""
    
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
