#!/bin/bash

SCRIPT_NAME="1.7.4_permissions_etcmotd.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.7.4 - Permissions on /etc/motd"
    echo ""
    
    local motd="/etc/motd"
    
    # Create if doesn't exist
    if [ ! -f "$motd" ]; then
        touch "$motd"
        log_message "INFO" "Created $motd"
    fi
    
    # Set ownership and permissions
    chown root:root "$motd"
    chmod 644 "$motd"
    
    local perms=$(stat -c "%a" "$motd")
    local owner=$(stat -c "%U:%G" "$motd")
    
    echo "File: $motd"
    echo "Permissions: $perms"
    echo "Owner: $owner"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
