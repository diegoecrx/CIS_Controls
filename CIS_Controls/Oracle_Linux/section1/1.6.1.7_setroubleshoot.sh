#!/bin/bash

SCRIPT_NAME="1.6.1.7_setroubleshoot.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.6.1.7 - Remove setroubleshoot"
    echo ""
    
    if ! rpm -q setroubleshoot &>/dev/null; then
        echo "setroubleshoot not installed"
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "Package not present"
    else
        echo "setroubleshoot is installed"
        echo "Removing package..."
        
        yum remove -y setroubleshoot &>/dev/null
        log_message "SUCCESS" "Removed setroubleshoot"
        
        echo "setroubleshoot removed"
        echo "Status: COMPLIANT"
    fi
    
    echo ""
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
