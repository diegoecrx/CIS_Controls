#!/bin/bash

SCRIPT_NAME="1.3.2_filesystem_integrity_regularly_checked.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

check_aide_installed() {
    rpm -q aide &>/dev/null
}

install_aide() {
    log_message "INFO" "Installing AIDE"
    if yum install -y aide &>/dev/null; then
        log_message "SUCCESS" "AIDE installed"
        return 0
    fi
    return 1
}

initialize_aide() {
    log_message "INFO" "Initializing AIDE database"
    echo "This may take several minutes..."
    if aide --init &>/dev/null; then
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz 2>/dev/null
        log_message "SUCCESS" "AIDE database initialized"
        return 0
    fi
    return 1
}

configure_aide_cron() {
    local cron_file="/etc/cron.daily/aide-check"
    
    cat > "$cron_file" << 'EOF'
#!/bin/bash
# CIS 1.3.2 - Daily AIDE integrity check
/usr/sbin/aide --check
EOF
    
    chmod 755 "$cron_file"
    log_message "SUCCESS" "Configured daily AIDE check"
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.3.2 - Filesystem Integrity Checking"
    echo ""
    
    if ! check_aide_installed; then
        echo "AIDE not installed"
        read -p "Install AIDE? [y/n]: " response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_aide || { echo "Install failed"; exit 1; }
            initialize_aide || { echo "Init failed"; exit 1; }
        else
            echo "Skipped"
            exit 0
        fi
    else
        echo "AIDE is installed"
    fi
    
    # Check if database exists
    if [ ! -f /var/lib/aide/aide.db.gz ]; then
        echo "Database not initialized"
        initialize_aide
    fi
    
    # Configure cron
    configure_aide_cron
    
    echo ""
    echo "Status: COMPLIANT"
    echo "AIDE will check filesystem integrity daily"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
