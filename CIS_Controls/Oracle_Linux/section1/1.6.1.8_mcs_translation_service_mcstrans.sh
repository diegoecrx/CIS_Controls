#!/bin/bash

SCRIPT_NAME="1.6.1.8_mcs_translation_service_mcstrans.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.6.1.8 - Remove mcstrans"
    echo ""
    
    if ! rpm -q mcstrans &>/dev/null; then
        echo "mcstrans not installed"
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "Package not present"
    else
        echo "mcstrans is installed"
        echo "Removing package..."
        
        systemctl stop mcstrans 2>/dev/null
        yum remove -y mcstrans &>/dev/null
        log_message "SUCCESS" "Removed mcstrans"
        
        echo "mcstrans removed"
        echo "Status: COMPLIANT"
    fi
    
    echo ""
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
