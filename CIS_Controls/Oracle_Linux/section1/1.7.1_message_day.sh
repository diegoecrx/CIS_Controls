#!/bin/bash

SCRIPT_NAME="1.7.1_message_day.sh"
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

configure_motd() {
    local motd="/etc/motd"
    
    backup_file "$motd" 2>/dev/null
    
    cat > "$motd" << 'EOF'
###############################################################################
#                           AUTHORIZED ACCESS ONLY                            #
###############################################################################
#                                                                             #
#  This system is for authorized use only. All activity is monitored and     #
#  logged. Unauthorized access is prohibited and will be prosecuted to the   #
#  fullest extent of the law.                                                #
#                                                                             #
###############################################################################
EOF
    
    chmod 644 "$motd"
    log_message "SUCCESS" "Configured /etc/motd"
}

configure_issue() {
    local issue="/etc/issue"
    
    backup_file "$issue" 2>/dev/null
    
    cat > "$issue" << 'EOF'
Authorized users only. All activity may be monitored and reported.
EOF
    
    chmod 644 "$issue"
    log_message "SUCCESS" "Configured /etc/issue"
}

configure_issue_net() {
    local issue_net="/etc/issue.net"
    
    backup_file "$issue_net" 2>/dev/null
    
    cat > "$issue_net" << 'EOF'
Authorized users only. All activity may be monitored and reported.
EOF
    
    chmod 644 "$issue_net"
    log_message "SUCCESS" "Configured /etc/issue.net"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.7.1 - Message of the Day"
    echo ""
    
    configure_motd
    configure_issue
    configure_issue_net
    
    echo "Login banners configured"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
