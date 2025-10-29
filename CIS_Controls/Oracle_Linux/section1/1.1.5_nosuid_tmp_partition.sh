#!/bin/bash

SCRIPT_NAME="1.1.5_nosuid_tmp_partition.sh"
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

add_tmp_nosuid() {
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    if grep -q "[[:space:]]/tmp[[:space:]]" "$fstab"; then
        if ! grep "[[:space:]]/tmp[[:space:]]" "$fstab" | grep -q "nosuid"; then
            sed -i '/[[:space:]]\/tmp[[:space:]]/ s/defaults/defaults,nosuid/' "$fstab"
            log_message "SUCCESS" "Added nosuid to /tmp in fstab"
        fi
    else
        echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,size=2G 0 0" >> "$fstab"
        log_message "SUCCESS" "Added tmpfs /tmp with nosuid to fstab"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.5 - nosuid on /tmp"
    echo "========================================"
    echo ""
    
    if ! mount | grep -q " on /tmp "; then
        echo "/tmp not separately mounted"
        add_tmp_nosuid
        echo "REBOOT REQUIRED"
        log_message "WARNING" "Reboot required"
    else
        local opts=$(mount | grep " on /tmp " | sed 's/.*(\(.*\))/\1/')
        echo "Current /tmp options: $opts"
        
        if echo "$opts" | grep -q "nosuid"; then
            echo "Status: COMPLIANT"
            log_message "SUCCESS" "CIS 1.1.5 COMPLIANT"
        else
            echo "Status: NON-COMPLIANT"
            add_tmp_nosuid
            
            if mount -o remount,nosuid /tmp 2>/dev/null; then
                echo "Remounted with nosuid"
                log_message "SUCCESS" "Remounted /tmp with nosuid"
            else
                echo "Reboot required"
                log_message "WARNING" "Reboot required"
            fi
        fi
    fi
    
    echo ""
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
