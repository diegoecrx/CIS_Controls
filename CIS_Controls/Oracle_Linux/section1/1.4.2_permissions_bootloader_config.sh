#!/bin/bash

SCRIPT_NAME="1.4.2_permissions_bootloader_config.sh"
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

fix_grub_permissions() {
    local grub_cfg="/boot/grub2/grub.cfg"
    
    if [ ! -f "$grub_cfg" ]; then
        log_message "ERROR" "GRUB config not found: $grub_cfg"
        return 1
    fi
    
    backup_file "$grub_cfg"
    
    # Set permissions to 600 (owner read/write only)
    chown root:root "$grub_cfg"
    chmod 600 "$grub_cfg"
    
    log_message "SUCCESS" "Set $grub_cfg permissions to 600"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.4.2 - Bootloader Config Permissions"
    echo ""
    
    local grub_cfg="/boot/grub2/grub.cfg"
    
    if [ ! -f "$grub_cfg" ]; then
        echo "GRUB config not found"
        log_message "ERROR" "Config file missing"
        exit 1
    fi
    
    local current_perms=$(stat -c "%a" "$grub_cfg")
    local current_owner=$(stat -c "%U:%G" "$grub_cfg")
    
    echo "File: $grub_cfg"
    echo "Current permissions: $current_perms"
    echo "Current owner: $current_owner"
    echo ""
    
    if [ "$current_perms" = "600" ] && [ "$current_owner" = "root:root" ]; then
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "Already compliant"
    else
        echo "Status: NON-COMPLIANT"
        echo "Required: 600 root:root"
        echo ""
        
        fix_grub_permissions
        
        echo "Fixed permissions:"
        ls -l "$grub_cfg"
        echo ""
        echo "Status: COMPLIANT"
    fi
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
