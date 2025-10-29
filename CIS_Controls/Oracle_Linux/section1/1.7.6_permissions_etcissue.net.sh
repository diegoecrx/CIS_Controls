#!/bin/bash

SCRIPT_NAME="1.7.6_permissions_etcissue.net.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.7.6 - Permissions on /etc/issue.net"
    echo ""
    
    local issue_net="/etc/issue.net"
    
    if [ ! -f "$issue_net" ]; then
        touch "$issue_net"
        log_message "INFO" "Created $issue_net"
    fi
    
    chown root:root "$issue_net"
    chmod 644 "$issue_net"
    
    local perms=$(stat -c "%a" "$issue_net")
    local owner=$(stat -c "%U:%G" "$issue_net")
    
    echo "File: $issue_net"
    echo "Permissions: $perms"
    echo "Owner: $owner"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
