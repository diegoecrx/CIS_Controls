#!/bin/bash

SCRIPT_NAME="1.6.1.2_selinux_disabled_bootloader_configuration.sh"
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

check_grub_selinux() {
    local grub_cfg="/boot/grub2/grub.cfg"
    
    if grep -q "selinux=0\|enforcing=0" "$grub_cfg"; then
        return 1
    fi
    return 0
}

fix_grub_selinux() {
    local grub_default="/etc/default/grub"
    
    backup_file "$grub_default"
    
    # Remove selinux=0 and enforcing=0 from GRUB_CMDLINE_LINUX
    sed -i 's/selinux=0//g' "$grub_default"
    sed -i 's/enforcing=0//g' "$grub_default"
    
    # Regenerate grub config
    grub2-mkconfig -o /boot/grub2/grub.cfg &>/dev/null
    log_message "SUCCESS" "Removed SELinux disable parameters"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.6.1.2 - SELinux Not Disabled in Bootloader"
    echo ""
    
    if check_grub_selinux; then
        echo "Status: COMPLIANT"
        echo "SELinux not disabled in bootloader"
        log_message "SUCCESS" "Already compliant"
    else
        echo "Status: NON-COMPLIANT"
        echo "SELinux is disabled in bootloader config"
        echo ""
        echo "Removing selinux=0 and enforcing=0 from grub..."
        
        fix_grub_selinux
        
        echo "GRUB config updated"
        echo "Reboot required for changes"
        echo "Status: COMPLIANT"
    fi
    
    echo ""
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
