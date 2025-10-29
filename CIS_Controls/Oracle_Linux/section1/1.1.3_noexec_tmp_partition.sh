#!/bin/bash

SCRIPT_NAME="1.1.3_noexec_tmp_partition.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

backup_file() {
    [ -f "$1" ] || return 1
    cp "$1" "$BACKUP_DIR/$(basename $1).$(date +%Y%m%d_%H%M%S).backup"
}

add_tmp_noexec() {
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    # Check if /tmp entry exists
    if grep -q "[[:space:]]/tmp[[:space:]]" "$fstab"; then
        # Add noexec if not present
        if ! grep "[[:space:]]/tmp[[:space:]]" "$fstab" | grep -q "noexec"; then
            sed -i '/[[:space:]]\/tmp[[:space:]]/ s/defaults/defaults,noexec/' "$fstab"
            log_message "SUCCESS" "Added noexec to /tmp in fstab"
        else
            log_message "INFO" "noexec already present for /tmp"
        fi
    else
        # No /tmp entry - add tmpfs
        echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,size=2G 0 0" >> "$fstab"
        log_message "SUCCESS" "Added tmpfs /tmp with noexec to fstab"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.3 - noexec on /tmp"
    echo "========================================"
    echo ""
    
    # Check if /tmp is mounted
    if ! mount | grep -q " on /tmp "; then
        log_message "WARNING" "/tmp not separately mounted"
        echo "/tmp is not a separate partition"
        echo ""
        echo "Will configure tmpfs with noexec option"
        add_tmp_noexec
        echo ""
        echo "REBOOT REQUIRED for tmpfs to take effect"
        log_message "WARNING" "Reboot required"
    else
        # Check current options
        local current_opts=$(mount | grep " on /tmp " | sed 's/.*(\(.*\))/\1/')
        log_message "INFO" "Current /tmp options: $current_opts"
        
        echo "/tmp is mounted separately"
        echo "Current options: $current_opts"
        echo ""
        
        if echo "$current_opts" | grep -q "noexec"; then
            echo "Status: COMPLIANT (has noexec)"
            log_message "SUCCESS" "/tmp has noexec - CIS 1.1.3 COMPLIANT"
        else
            echo "Status: NON-COMPLIANT (missing noexec)"
            log_message "WARNING" "/tmp missing noexec"
            
            add_tmp_noexec
            
            echo ""
            echo "Added noexec to /etc/fstab"
            echo "Attempting to remount..."
            
            if mount -o remount,noexec /tmp 2>/dev/null; then
                echo "Remounted successfully with noexec"
                log_message "SUCCESS" "Remounted /tmp with noexec"
            else
                echo "Could not remount - reboot required"
                log_message "WARNING" "Reboot required"
            fi
        fi
    fi
    
    echo ""
    echo "========================================"
    echo "Current Status"
    echo "========================================"
    mount | grep " on /tmp " || echo "/tmp not separately mounted"
    echo ""
    grep "/tmp" /etc/fstab 2>/dev/null || echo "No /tmp entry in fstab"
    echo ""
    
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
