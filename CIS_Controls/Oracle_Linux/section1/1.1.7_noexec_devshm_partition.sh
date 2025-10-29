#!/bin/bash

SCRIPT_NAME="1.1.7_noexec_devshm_partition.sh"
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

add_devshm_noexec() {
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    if grep -q "[[:space:]]/dev/shm[[:space:]]" "$fstab"; then
        if ! grep "[[:space:]]/dev/shm[[:space:]]" "$fstab" | grep -q "noexec"; then
            sed -i '/[[:space:]]\/dev\/shm[[:space:]]/ s/defaults/defaults,noexec/' "$fstab"
            log_message "SUCCESS" "Added noexec to /dev/shm in fstab"
        fi
    else
        echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> "$fstab"
        log_message "SUCCESS" "Added /dev/shm with noexec to fstab"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.7 - noexec on /dev/shm"
    echo "========================================"
    echo ""
    
    local opts=$(mount | grep " on /dev/shm " | sed 's/.*(\(.*\))/\1/')
    echo "Current /dev/shm options: $opts"
    
    if echo "$opts" | grep -q "noexec"; then
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "CIS 1.1.7 COMPLIANT"
    else
        echo "Status: NON-COMPLIANT"
        add_devshm_noexec
        
        if mount -o remount,noexec /dev/shm 2>/dev/null; then
            echo "Remounted with noexec"
            log_message "SUCCESS" "Remounted /dev/shm with noexec"
        else
            echo "Reboot required"
            log_message "WARNING" "Reboot required"
        fi
    fi
    
    echo ""
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
