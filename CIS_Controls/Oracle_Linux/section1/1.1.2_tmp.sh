#!/bin/bash

SCRIPT_NAME="1.1.2_tmp.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

backup_file() {
    [ -f "$1" ] || return 1
    cp "$1" "$BACKUP_DIR/$(basename $1).$(date +%Y%m%d_%H%M%S).backup"
    log_message "INFO" "Backed up $1"
}

check_tmp_partition() {
    if mount | grep -q " on /tmp "; then
        return 0
    fi
    return 1
}

configure_tmp_tmpfs() {
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    # Check if tmpfs /tmp entry exists
    if grep -q "^tmpfs[[:space:]]*/tmp" "$fstab"; then
        log_message "INFO" "tmpfs /tmp entry already exists"
        
        # Ensure it has security options
        if ! grep "^tmpfs[[:space:]]*/tmp" "$fstab" | grep -q "noexec"; then
            sed -i '/^tmpfs[[:space:]]*\/tmp/ s/tmpfs/tmpfs defaults,nodev,nosuid,noexec/' "$fstab"
            log_message "SUCCESS" "Added security options to tmpfs /tmp"
        fi
    else
        # Add new tmpfs entry
        echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,size=2G 0 0" >> "$fstab"
        log_message "SUCCESS" "Added tmpfs /tmp entry to fstab"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    if ! check_tmp_partition; then
        log_message "WARNING" "/tmp is not a separate partition"
        
        echo ""
        echo "========================================"
        echo "CIS 1.1.2 - /tmp Configuration"
        echo "========================================"
        echo ""
        echo "/tmp is not mounted as separate partition"
        echo ""
        echo "Recommended: Configure tmpfs for /tmp"
        echo "This provides:"
        echo "  - Separate /tmp from root filesystem"
        echo "  - Security options: noexec,nodev,nosuid"
        echo "  - Size control (prevents filling root)"
        echo ""
        read -p "Apply tmpfs configuration? [y/n]: " response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            configure_tmp_tmpfs
            
            echo ""
            echo "Configuration added to /etc/fstab"
            echo "REBOOT REQUIRED for changes to take effect"
            echo ""
            log_message "WARNING" "REBOOT REQUIRED"
        else
            log_message "INFO" "User declined tmpfs configuration"
            echo "Configuration skipped"
        fi
    else
        log_message "INFO" "/tmp is already a separate partition"
        
        # Check mount options
        local current_opts=$(mount | grep " on /tmp " | sed 's/.*(\(.*\))/\1/')
        log_message "INFO" "Current /tmp options: $current_opts"
        
        echo ""
        echo "/tmp is mounted separately"
        echo "Current options: $current_opts"
        echo ""
        
        if echo "$current_opts" | grep -q "noexec.*nodev.*nosuid\|nodev.*noexec.*nosuid\|nosuid.*noexec.*nodev"; then
            echo "Status: COMPLIANT"
            log_message "SUCCESS" "/tmp has required security options"
        else
            echo "Status: MISSING SECURITY OPTIONS"
            log_message "WARNING" "/tmp missing some security options"
            
            backup_file "/etc/fstab"
            
            # Add missing options
            sed -i '/[[:space:]]\/tmp[[:space:]]/ s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
            
            echo ""
            echo "Added security options to /etc/fstab"
            echo "Run: mount -o remount /tmp"
            echo "Or reboot for changes to take effect"
            log_message "SUCCESS" "Updated /etc/fstab"
        fi
    fi
    
    echo ""
    echo "========================================"
    echo "Current /tmp Status"
    echo "========================================"
    mount | grep " on /tmp " || echo "/tmp not separately mounted"
    echo ""
    grep "/tmp" /etc/fstab 2>/dev/null || echo "No /tmp entry in fstab"
    echo ""
    
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
