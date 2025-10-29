#!/bin/bash

SCRIPT_NAME="1.1.23_disable_automounting.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

install_autofs() {
    log_message "INFO" "Installing autofs package"
    if yum install -y autofs &>/dev/null; then
        log_message "SUCCESS" "autofs package installed"
        return 0
    else
        log_message "ERROR" "Failed to install autofs"
        return 1
    fi
}

check_autofs_status() {
    if systemctl is-enabled autofs 2>/dev/null | grep -q "enabled"; then
        return 0
    fi
    return 1
}

disable_autofs() {
    log_message "INFO" "Disabling autofs service"
    
    if systemctl stop autofs 2>/dev/null; then
        log_message "SUCCESS" "Stopped autofs service"
    fi
    
    if systemctl disable autofs 2>/dev/null; then
        log_message "SUCCESS" "Disabled autofs service"
    fi
    
    if systemctl mask autofs 2>/dev/null; then
        log_message "SUCCESS" "Masked autofs service"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.23 - Disable Automounting"
    echo "========================================"
    echo ""
    
    # Check if autofs is installed
    if ! rpm -q autofs &>/dev/null; then
        log_message "WARNING" "autofs is not installed"
        echo "autofs is not installed"
        echo ""
        echo "CIS Benchmark requires testing that autofs is disabled."
        echo "Installing autofs to properly disable it..."
        echo ""
        
        if install_autofs; then
            echo "autofs installed successfully"
            echo ""
        else
            echo "ERROR: Failed to install autofs"
            log_message "ERROR" "Cannot proceed without autofs package"
            return 1
        fi
    else
        log_message "INFO" "autofs package is already installed"
        echo "autofs package is installed"
        echo ""
    fi
    
    # Check if enabled
    if check_autofs_status; then
        log_message "WARNING" "autofs is enabled (non-compliant)"
        echo "Current status: ENABLED (non-compliant)"
    else
        log_message "INFO" "autofs is disabled"
        echo "Current status: DISABLED"
    fi
    
    echo ""
    echo "Automounting allows automatic mounting of removable media"
    echo "and network shares. CIS requires it to be disabled."
    echo ""
    
    # Always disable/mask it
    disable_autofs
    
    echo ""
    echo "========================================"
    echo "Remediation Complete"
    echo "========================================"
    echo ""
    
    # Verify final status
    if systemctl is-masked autofs &>/dev/null; then
        echo "Status: COMPLIANT"
        echo "  - autofs is installed"
        echo "  - autofs is disabled"
        echo "  - autofs is masked"
        log_message "SUCCESS" "System is now CIS 1.1.23 COMPLIANT"
    else
        echo "Status: Check required"
        echo ""
        systemctl status autofs 2>/dev/null | head -5
    fi
    
    echo ""
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
