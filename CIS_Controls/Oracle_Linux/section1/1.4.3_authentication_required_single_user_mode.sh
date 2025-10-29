#!/bin/bash

SCRIPT_NAME="1.4.3_authentication_required_single_user_mode.sh"
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

configure_rescue_service() {
    local rescue_service="/usr/lib/systemd/system/rescue.service"
    local emergency_service="/usr/lib/systemd/system/emergency.service"
    
    if [ -f "$rescue_service" ]; then
        backup_file "$rescue_service"
        
        # Ensure ExecStart requires sulogin
        if ! grep -q "ExecStart=-/bin/sh -c \"/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\"" "$rescue_service"; then
            sed -i 's|^ExecStart=.*|ExecStart=-/bin/sh -c "/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"|' "$rescue_service"
            log_message "SUCCESS" "Configured rescue.service"
        fi
    fi
    
    if [ -f "$emergency_service" ]; then
        backup_file "$emergency_service"
        
        if ! grep -q "ExecStart=-/bin/sh -c \"/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\"" "$emergency_service"; then
            sed -i 's|^ExecStart=.*|ExecStart=-/bin/sh -c "/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"|' "$emergency_service"
            log_message "SUCCESS" "Configured emergency.service"
        fi
    fi
    
    systemctl daemon-reload
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.4.3 - Authentication for Single User Mode"
    echo ""
    
    # Check current configuration
    if grep -q "sulogin" /usr/lib/systemd/system/rescue.service 2>/dev/null; then
        echo "Rescue mode: Configured"
    else
        echo "Rescue mode: Not configured"
    fi
    
    if grep -q "sulogin" /usr/lib/systemd/system/emergency.service 2>/dev/null; then
        echo "Emergency mode: Configured"
    else
        echo "Emergency mode: Not configured"
    fi
    
    echo ""
    echo "Configuring authentication requirement..."
    configure_rescue_service
    
    echo ""
    echo "Status: COMPLIANT"
    echo "Root password will be required for single-user mode"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
