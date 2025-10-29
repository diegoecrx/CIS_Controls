#!/bin/bash

SCRIPT_NAME="1.8.3_last_logged_user_display_disabled.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.8.3 - Disable Last Logged User Display"
    echo ""
    
    if ! rpm -q gdm &>/dev/null; then
        echo "GDM not installed"
        echo "Status: NOT APPLICABLE"
        log_message "INFO" "GDM not present - skipping"
        return 0
    fi
    
    local gdm_profile="/etc/dconf/profile/gdm"
    local gdm_settings="/etc/dconf/db/gdm.d/00-login-screen"
    
    # Create profile
    mkdir -p "$(dirname $gdm_profile)"
    cat > "$gdm_profile" << 'EOF'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
    
    # Create settings to disable user list
    mkdir -p "$(dirname $gdm_settings)"
    cat > "$gdm_settings" << 'EOF'
[org/gnome/login-screen]
disable-user-list=true
EOF
    
    # Update dconf
    dconf update
    
    log_message "SUCCESS" "Disabled user list display"
    echo "Last logged user display disabled"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
