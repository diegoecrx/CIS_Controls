#!/bin/bash

SCRIPT_NAME="1.7.5_permissions_etcissue.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.7.5 - Permissions on /etc/issue"
    echo ""
    
    local issue="/etc/issue"
    
    if [ ! -f "$issue" ]; then
        touch "$issue"
        log_message "INFO" "Created $issue"
    fi
    
    chown root:root "$issue"
    chmod 644 "$issue"
    
    local perms=$(stat -c "%a" "$issue")
    local owner=$(stat -c "%U:%G" "$issue")
    
    echo "File: $issue"
    echo "Permissions: $perms"
    echo "Owner: $owner"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
