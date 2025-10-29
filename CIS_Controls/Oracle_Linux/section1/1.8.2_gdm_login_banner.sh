#!/bin/bash

SCRIPT_NAME="1.8.2_gdm_login_banner.sh"
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
    echo "CIS 1.8.2 - GDM Login Banner"
    echo ""
    
    if ! rpm -q gdm &>/dev/null; then
        echo "GDM not installed"
        echo "Status: NOT APPLICABLE"
        log_message "INFO" "GDM not present - skipping"
        return 0
    fi
    
    local gdm_profile="/etc/dconf/profile/gdm"
    local gdm_banner_dir="/etc/dconf/db/gdm.d"
    local banner_file="$gdm_banner_dir/01-banner-message"
    
    # Create profile
    mkdir -p "$(dirname $gdm_profile)"
    cat > "$gdm_profile" << 'EOF'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
    
    # Create banner configuration
    mkdir -p "$gdm_banner_dir"
    cat > "$banner_file" << 'EOF'
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='Authorized access only. All activity may be monitored and reported.'
EOF
    
    # Update dconf
    dconf update
    
    log_message "SUCCESS" "Configured GDM banner"
    echo "GDM login banner configured"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
