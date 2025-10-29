#!/bin/bash

SCRIPT_NAME="1.1.24_disable_usb_storage.sh"
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

check_usb_storage_status() {
    # Check if module is loaded
    if lsmod | grep -q "^usb_storage"; then
        return 0  # Module is loaded
    fi
    return 1
}

disable_usb_storage() {
    local modprobe_conf="/etc/modprobe.d/usb_storage.conf"
    
    log_message "INFO" "Disabling usb-storage module"
    
    # Create modprobe config
    cat > "$modprobe_conf" << 'EOF'
# CIS 1.1.24 - Disable USB storage
install usb-storage /bin/true
blacklist usb-storage
EOF
    
    log_message "SUCCESS" "Created $modprobe_conf"
    
    # Unload module if currently loaded
    if lsmod | grep -q "^usb_storage"; then
        if rmmod usb-storage 2>/dev/null; then
            log_message "SUCCESS" "Unloaded usb-storage module"
        else
            log_message "WARNING" "Could not unload usb-storage (may be in use)"
        fi
    fi
    
    # Update initramfs
    dracut -f 2>/dev/null && log_message "SUCCESS" "Updated initramfs"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "========================================"
    echo "CIS 1.1.24 - Disable USB Storage"
    echo "========================================"
    echo ""
    
    # Check current status
    if check_usb_storage_status; then
        log_message "WARNING" "usb-storage module is loaded"
        echo "Current status: USB storage ENABLED (non-compliant)"
    else
        log_message "INFO" "usb-storage module is not loaded"
        echo "Current status: USB storage not currently active"
    fi
    
    echo ""
    
    # Check if already disabled in modprobe
    if [ -f /etc/modprobe.d/usb_storage.conf ]; then
        if grep -q "install usb-storage /bin/true" /etc/modprobe.d/usb_storage.conf; then
            log_message "SUCCESS" "usb-storage already disabled in modprobe"
            echo "Configuration: Already disabled in modprobe"
            echo "Status: COMPLIANT"
            echo ""
            log_message "SUCCESS" "System is CIS 1.1.24 COMPLIANT"
            return 0
        fi
    fi
    
    echo "This will completely disable USB storage devices."
    echo "USB keyboards and mice will still work (different driver)."
    echo ""
    read -p "Disable USB storage? [y/n]: " response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        disable_usb_storage
        
        echo ""
        echo "========================================"
        echo "Remediation Complete"
        echo "========================================"
        echo ""
        echo "USB storage has been disabled"
        echo "Status: COMPLIANT"
        echo ""
        echo "Note: USB storage devices will no longer be accessible"
        echo ""
        log_message "SUCCESS" "USB storage disabled - CIS 1.1.24 COMPLIANT"
    else
        log_message "INFO" "User declined to disable USB storage"
        echo ""
        echo "USB storage remains enabled"
        echo "Status: NON-COMPLIANT"
        echo ""
    fi
    
    log_message "SUCCESS" "Remediation completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
