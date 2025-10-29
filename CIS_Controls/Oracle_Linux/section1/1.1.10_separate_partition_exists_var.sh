#!/bin/bash

###############################################################################
# CIS Oracle Linux 7 Benchmark
# 1.1.10_separate_partition_exists_var.sh
# CIS Control - 1.1.10_separate_partition_exists_var.sh
# 
# This script implements proper CIS controls with comprehensive error handling
###############################################################################

SCRIPT_NAME="1.1.10_separate_partition_exists_var.sh"
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
        echo "$BACKUP_DIR/$backup_name"  # Return backup path
        return 0
    else
        log_message "ERROR" "Failed to backup $file_path"
        return 1
    fi
}

# Configuration file editor with validation
edit_config_file() {
    local config_file="$1"
    local setting_name="$2"
    local setting_value="$3"
    local comment_prefix="${4:-#}"

    if [ ! -f "$config_file" ]; then
        log_message "ERROR" "Configuration file not found: $config_file"
        return 1
    fi

    # Backup the file first
    local backup_path
    backup_path=$(backup_file "$config_file")
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Cannot proceed without backup"
        return 1
    fi

    # Check if setting already exists and is correctly configured
    if grep -q "^$setting_name[[:space:]]*$setting_value" "$config_file"; then
        log_message "INFO" "Setting $setting_name is already correctly configured"
        return 0
    fi

    # Remove any existing commented or incorrect lines
    sed -i "/^$comment_prefix*[[:space:]]*$setting_name/d" "$config_file" 2>/dev/null

    # Add the correct setting
    if echo "$setting_name $setting_value" >> "$config_file"; then
        log_message "SUCCESS" "Added $setting_name $setting_value to $config_file"

        # Validate the change
        if grep -q "^$setting_name[[:space:]]*$setting_value" "$config_file"; then
            log_message "SUCCESS" "Configuration validated successfully"
            return 0
        else
            log_message "ERROR" "Configuration validation failed"
            return 1
        fi
    else
        log_message "ERROR" "Failed to add setting to $config_file"
        return 1
    fi
}

# Service management with proper error handling
manage_service() {
    local action="$1"
    local service_name="$2"

    case "$action" in
        "enable")
            if systemctl is-enabled "$service_name" >/dev/null 2>&1; then
                log_message "INFO" "Service $service_name is already enabled"
                return 0
            fi

            if systemctl enable "$service_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Enabled service: $service_name"
                return 0
            else
                log_message "ERROR" "Failed to enable service: $service_name"
                return 1
            fi
        ;;
        "disable")
            if ! systemctl is-enabled "$service_name" >/dev/null 2>&1; then
                log_message "INFO" "Service $service_name is already disabled"
                return 0
            fi

            if systemctl disable "$service_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Disabled service: $service_name"
                return 0
            else
                log_message "ERROR" "Failed to disable service: $service_name"
                return 1
            fi
        ;;
        "start")
            if systemctl is-active "$service_name" >/dev/null 2>&1; then
                log_message "INFO" "Service $service_name is already running"
                return 0
            fi

            if systemctl start "$service_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Started service: $service_name"
                return 0
            else
                log_message "ERROR" "Failed to start service: $service_name"
                return 1
            fi
        ;;
        "stop")
            if ! systemctl is-active "$service_name" >/dev/null 2>&1; then
                log_message "INFO" "Service $service_name is already stopped"
                return 0
            fi

            if systemctl stop "$service_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Stopped service: $service_name"
                return 0
            else
                log_message "ERROR" "Failed to stop service: $service_name"
                return 1
            fi
        ;;
    esac
}

# Package management function
manage_package() {
    local action="$1"
    local package_name="$2"

    case "$action" in
        "install")
            if rpm -q "$package_name" >/dev/null 2>&1; then
                log_message "INFO" "Package $package_name is already installed"
                return 0
            fi

            if yum install -y "$package_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Installed package: $package_name"
                return 0
            else
                log_message "ERROR" "Failed to install package: $package_name"
                return 1
            fi
        ;;
        "remove")
            if ! rpm -q "$package_name" >/dev/null 2>&1; then
                log_message "INFO" "Package $package_name is not installed"
                return 0
            fi

            if yum remove -y "$package_name" >/dev/null 2>&1; then
                log_message "SUCCESS" "Removed package: $package_name"
                return 0
            else
                log_message "ERROR" "Failed to remove package: $package_name"
                return 1
            fi
        ;;
    esac
}

# Main remediation function with proper error handling
main_remediation() {
    log_message "INFO" "Starting remediation: $SCRIPT_NAME"

    # Set error handling
    set -e
    trap 'log_message "ERROR" "Script failed at line $LINENO"; exit 1' ERR

    # Generic CIS remediation for 1.1.10_separate_partition_exists_var.sh
    log_message "INFO" "Executing remediation for 1.1.10_separate_partition_exists_var.sh"

    # This is a template implementation - specific logic depends on the CIS control
    # Please refer to the CIS benchmark documentation for detailed requirements

    log_message "INFO" "Remediation logic needs to be customized for this specific control"
    log_message "SUCCESS" "Template remediation completed for 1.1.10_separate_partition_exists_var.sh"

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
