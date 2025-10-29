#!/bin/bash

SCRIPT_NAME="1.5.1_core_dumps_restricted.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"

mkdir -p "$BACKUP_DIR" 2>/dev/null

log_message() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$1] [$SCRIPT_NAME] ${@:2}" | tee -a "$LOG_FILE"
}

configure_limits() {
    local limits_file="/etc/security/limits.conf"
    
    if ! grep -q "^\* hard core 0" "$limits_file"; then
        echo "* hard core 0" >> "$limits_file"
        log_message "SUCCESS" "Added hard core limit"
    fi
}

configure_sysctl() {
    local sysctl_file="/etc/sysctl.d/99-coredump.conf"
    
    cat > "$sysctl_file" << 'EOF'
# CIS 1.5.1 - Disable core dumps
fs.suid_dumpable = 0
EOF
    
    sysctl -p "$sysctl_file" &>/dev/null
    log_message "SUCCESS" "Configured sysctl"
}

disable_systemd_coredump() {
    if systemctl is-enabled systemd-coredump.socket &>/dev/null; then
        systemctl disable systemd-coredump.socket &>/dev/null
        systemctl stop systemd-coredump.socket &>/dev/null
        log_message "SUCCESS" "Disabled systemd-coredump"
    fi
}

main_remediation() {
    log_message "INFO" "Starting remediation"
    
    echo ""
    echo "CIS 1.5.1 - Restrict Core Dumps"
    echo ""
    
    configure_limits
    configure_sysctl
    disable_systemd_coredump
    
    echo "Core dumps restricted"
    echo "Status: COMPLIANT"
    echo ""
    
    log_message "SUCCESS" "Completed"
}

[ "$EUID" -ne 0 ] && { echo "Must run as root"; exit 1; }
main_remediation
