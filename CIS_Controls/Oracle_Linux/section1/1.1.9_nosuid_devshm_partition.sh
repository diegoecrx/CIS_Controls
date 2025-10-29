#!/bin/bash

SCRIPT_NAME="1.1.9_nosuid_devshm_partition.sh"
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

add_devshm_nosuid() {
    local fstab="/etc/fstab"
    backup_file "$fstab"
    
    if grep -q "[[:space:]]/dev/shm[[:space:]]" "$fstab"; then
        if ! grep "[[:space:]]/dev/shm[[:space:]]" "$fstab" | grep -q "nosuid"; then
            sed -i '/[[:space:]]\/dev\/shm[[:space:]]/ s/defaults/defaults,nosuid/' "$fstab"
            log_message "SUCCESS" "Added nosuid to /dev/shm"
        fi
    else
        echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> "$fstab"
        log_message "SUCCESS" "Added /dev/shm with nosuid"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.1.9 - nosuid on /dev/shm"
    echo ""
    
    local opts=$(mount | grep " on /dev/shm " | sed 's/.*(\(.*\))/\1/')
    echo "Current: $opts"
    
    if echo "$opts" | grep -q "nosuid"; then
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "COMPLIANT"
    else
        echo "Status: NON-COMPLIANT"
        add_devshm_nosuid
        mount -o remount,nosuid /dev/shm 2>/dev/null && echo "Remounted" || echo "Reboot required"
    fi
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
