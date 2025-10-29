#!/bin/bash

###############################################################################
# CIS Oracle Linux 7 Benchmark
# 1.1.1.3_mounting_udf_filesystems_disabled.sh
# CIS Control - 1.1.1.3_mounting_udf_filesystems_disabled.sh
#
# This script implements proper CIS controls with comprehensive error handling
###############################################################################

SCRIPT_NAME="1.1.1.3_mounting_udf_filesystems_disabled.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"
ERROR_LOG="/var/log/cis_error_analysis.log"

# Create backup directory
mkdir -p "$BACKUP_DIR" 2>/dev/null || {
    echo "Failed to create backup directory: $BACKUP_DIR"
    exit 1
}

# Enhanced logging function with error categorization
log_message() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] [$SCRIPT_NAME] $message" | tee -a "$LOG_FILE"
    
    # Also log to error log if it's an error
    if [ "$level" = "ERROR" ]; then
        echo "[$timestamp] [$SCRIPT_NAME] ERROR: $message" >> "$ERROR_LOG"
    fi
}

# Enhanced backup function with validation
backup_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        log_message "WARNING" "File does not exist for backup: $file_path"
        return 1
    fi
    
    if [ ! -r "$file_path" ]; then
        log_message "ERROR" "Cannot read file for backup: $file_path"
        return 1
    fi
    
    local backup_name="$(basename "$file_path").$(date +%Y%m%d_%H%M%S).backup"
    
    if cp "$file_path" "$BACKUP_DIR/$backup_name" 2>/dev/null; then
        log_message "INFO" "Backed up $file_path to $BACKUP_DIR/$backup_name"
        echo "$BACKUP_DIR/$backup_name" # Return backup path
        return 0
    else
        log_message "ERROR" "Failed to backup $file_path"
        return 1
    fi
}

# Main remediation function with proper error handling
main_remediation() {
    log_message "INFO" "Starting remediation: $SCRIPT_NAME"
    
    # Set error handling
    set -e
    trap 'log_message "ERROR" "Script failed at line $LINENO"; exit 1' ERR
    
    # Disable UDF filesystem mounting
    local modprobe_conf="/etc/modprobe.d/udf.conf"
    
    # Check if udf module is currently loaded
    if lsmod | grep -q "^udf"; then
        log_message "WARNING" "udf module is currently loaded"
    fi
    
    # Create or update modprobe configuration to disable udf
    if [ ! -f "$modprobe_conf" ]; then
        log_message "INFO" "Creating $modprobe_conf"
        echo "install udf /bin/true" > "$modprobe_conf"
        log_message "SUCCESS" "Created $modprobe_conf with udf disabled"
    else
        # Backup existing file
        backup_file "$modprobe_conf"
        
        # Check if udf is already disabled
        if grep -q "^install udf /bin/true" "$modprobe_conf"; then
            log_message "INFO" "udf is already disabled in $modprobe_conf"
        else
            # Remove any existing udf entries
            sed -i '/^install udf/d' "$modprobe_conf" 2>/dev/null || true
            
            # Add the disable directive
            echo "install udf /bin/true" >> "$modprobe_conf"
            log_message "SUCCESS" "Updated $modprobe_conf to disable udf"
        fi
    fi
    
    # Unload the module if it's currently loaded
    if lsmod | grep -q "^udf"; then
        if rmmod udf 2>/dev/null; then
            log_message "SUCCESS" "Unloaded udf kernel module"
        else
            log_message "WARNING" "Could not unload udf module (may be in use)"
        fi
    fi
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        log_message "SUCCESS" "Remediation completed successfully: $SCRIPT_NAME"
    else
        log_message "ERROR" "Remediation failed: $SCRIPT_NAME (exit code: $exit_code)"
    fi
    
    return $exit_code
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Verify running as root
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        log_message "ERROR" "Script must be run as root"
        exit 1
    fi
    
    # Execute remediation
    main_remediation
    exit $?
fi
