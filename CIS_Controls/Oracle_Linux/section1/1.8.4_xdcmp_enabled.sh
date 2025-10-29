#!/bin/bash

SCRIPT_NAME="1.8.4_xdcmp_enabled.sh"
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

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.8.4 - Disable XDMCP"
    echo ""
    
    if ! rpm -q gdm &>/dev/null; then
        echo "GDM not installed"
        echo "Status: NOT APPLICABLE"
        log_message "INFO" "GDM not present - skipping"
        return 0
    fi
    
    local gdm_custom="/etc/gdm/custom.conf"
    
    if [ ! -f "$gdm_custom" ]; then
        mkdir -p /etc/gdm
        touch "$gdm_custom"
    fi
    
    backup_file "$gdm_custom"
    
    # Check if XDMCP section exists
    if ! grep -q "^\[xdmcp\]" "$gdm_custom"; then
        echo "" >> "$gdm_custom"
        echo "[xdmcp]" >> "$gdm_custom"
        echo "Enable=false" >> "$gdm_custom"
    else
        # Update existing section
        sed -i '/^\[xdmcp\]/,/^\[/s/^Enable=.*/Enable=false/' "$gdm_custom"
    fi
    
    log_message "SUCCESS" "Disabled XDMCP"
    echo "XDMCP disabled in GDM configuration"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
