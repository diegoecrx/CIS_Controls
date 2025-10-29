#!/bin/bash

SCRIPT_NAME="1.7.2_local_login_warning_banner.sh"
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
    echo "CIS 1.7.2 - Local Login Warning Banner"
    echo ""
    
    local issue="/etc/issue"
    backup_file "$issue" 2>/dev/null
    
    cat > "$issue" << 'EOF'
###############################################################################
#                          AUTHORIZED ACCESS ONLY                             #
###############################################################################
Unauthorized access to this system is forbidden and will be prosecuted by law.
By accessing this system, you agree that your actions may be monitored.
EOF
    
    chmod 644 "$issue"
    chown root:root "$issue"
    
    # Remove OS info
    sed -i '/\\[mrsv]/d' "$issue"
    
    echo "Configured /etc/issue"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
