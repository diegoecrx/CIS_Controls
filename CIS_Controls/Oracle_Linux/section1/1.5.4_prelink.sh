#!/bin/bash

SCRIPT_NAME="1.5.4_prelink.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.5.4 - Ensure prelink is disabled"
    echo ""
    
    if ! rpm -q prelink &>/dev/null; then
        echo "prelink not installed"
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "prelink not present"
    else
        echo "prelink is installed"
        echo "Removing prelink..."
        
        # Restore binaries before removal
        if command -v prelink &>/dev/null; then
            prelink -ua 2>/dev/null
            log_message "INFO" "Restored prelinked binaries"
        fi
        
        # Remove package
        yum remove -y prelink &>/dev/null
        log_message "SUCCESS" "Removed prelink package"
        
        echo "prelink removed"
        echo "Status: COMPLIANT"
    fi
    
    echo ""
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
