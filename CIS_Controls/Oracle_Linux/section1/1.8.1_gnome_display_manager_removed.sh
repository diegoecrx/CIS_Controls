#!/bin/bash

SCRIPT_NAME="1.8.1_gnome_display_manager_removed.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.8.1 - Remove GNOME Display Manager"
    echo ""
    
    if ! rpm -q gdm &>/dev/null; then
        echo "GDM not installed"
        echo "Status: COMPLIANT"
        log_message "SUCCESS" "GDM not present"
    else
        echo "GDM is installed"
        echo ""
        echo "WARNING: This will remove the graphical interface"
        read -p "Remove GDM? [y/n]: " response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            systemctl stop gdm 2>/dev/null
            systemctl disable gdm 2>/dev/null
            yum remove -y gdm &>/dev/null
            
            log_message "SUCCESS" "Removed GDM"
            echo "GDM removed"
            echo "Status: COMPLIANT"
        else
            log_message "INFO" "User declined removal"
            echo "GDM remains installed"
            echo "Status: NON-COMPLIANT"
        fi
    fi
    
    echo ""
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
