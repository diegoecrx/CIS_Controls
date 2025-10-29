#!/bin/bash

###############################################################################
# CIS Oracle Linux 7 Benchmark
# 1.1.12_vartmp_partition_noexec.sh
# CIS Control - 1.1.12_vartmp_partition_noexec.sh

# This script implements proper CIS controls with comprehensive error handling
###############################################################################

SCRIPT_NAME="1.1.12_vartmp_partition_noexec.sh"
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
        echo "$BACKUP_DIR/$backup_name"
        return 0
    else
        log_message "ERROR" "Failed to backup $file_path"
        return 1
    fi
}

# Function to check if /var/tmp is a separate partition
check_vartmp_partition() {
    if mount | grep -q "on /var/tmp type"; then
        log_message "INFO" "/var/tmp is a separate partition"
        return 0
    else
        log_message "WARNING" "/var/tmp is not a separate partition"
        return 1
    fi
}

# NEW: Function to create bind mount for /var/tmp
create_vartmp_bind_mount() {
    log_message "INFO" "Creating bind mount for /var/tmp to /tmp"

    # Backup current /var/tmp contents
    local backup_path="$BACKUP_DIR/var_tmp_contents_$(date +%Y%m%d_%H%M%S)"
    if [ -d /var/tmp ] && [ "$(ls -A /var/tmp 2>/dev/null)" ]; then
        log_message "INFO" "Backing up /var/tmp contents to $backup_path"
        mkdir -p "$backup_path"
        cp -a /var/tmp/* "$backup_path/" 2>/dev/null || {
            log_message "WARNING" "Some files could not be backed up from /var/tmp"
        }
    fi

    # Clear /var/tmp directory
    log_message "INFO" "Clearing /var/tmp directory"
    rm -rf /var/tmp/* 2>/dev/null || true
    rm -rf /var/tmp/.* 2>/dev/null || true

    # Create bind mount
    log_message "INFO" "Mounting /tmp to /var/tmp as bind mount"
    if mount --bind /tmp /var/tmp; then
        log_message "SUCCESS" "Bind mount created successfully"
    else
        log_message "ERROR" "Failed to create bind mount"
        return 1
    fi

    # Add to /etc/fstab for persistence
    local fstab="/etc/fstab"
    backup_file "$fstab"

    if grep -q "^/tmp[[:space:]]/var/tmp[[:space:]]none[[:space:]]bind" "$fstab"; then
        log_message "INFO" "Bind mount entry already exists in /etc/fstab"
    else
        echo "/tmp /var/tmp none bind 0 0" >> "$fstab"
        log_message "SUCCESS" "Added bind mount entry to /etc/fstab"
    fi

    # Restore backed up files if any
    if [ -d "$backup_path" ] && [ "$(ls -A $backup_path 2>/dev/null)" ]; then
        log_message "INFO" "Restoring backed up files to /var/tmp"
        cp -a "$backup_path"/* /var/tmp/ 2>/dev/null || {
            log_message "WARNING" "Some files could not be restored. Manual check required: $backup_path"
        }
    fi

    log_message "SUCCESS" "Bind mount setup completed"
    return 0
}

# NEW: Function to prompt user for remediation choice
prompt_user_for_remediation() {
    echo ""
    echo "=========================================================================="
    echo "  CIS Benchmark Requirement Not Met"
    echo "=========================================================================="
    echo ""
    echo "Issue: /var/tmp is NOT configured as a separate partition"
    echo ""
    echo "CIS Benchmark 1.1.12 requires /var/tmp to be a separate partition"
    echo "with the 'noexec' option to prevent execution of binaries."
    echo ""
    echo "Recommended Remediation:"
    echo "  Create a bind mount from /tmp to /var/tmp. This will:"
    echo "  - Make /var/tmp inherit all mount options from /tmp (including noexec)"
    echo "  - Persist across reboots via /etc/fstab entry"
    echo "  - Backup and restore existing /var/tmp contents"
    echo ""
    echo "=========================================================================="
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "  1) Apply recommended remediation (create bind mount)"
    echo "  2) Skip remediation (system will remain non-compliant)"
    echo "  3) Exit script"
    echo ""

    while true; do
        read -p "Enter your choice [1-3]: " choice
        case $choice in
            1)
                log_message "INFO" "User selected: Apply remediation"
                return 0
                ;;
            2)
                log_message "INFO" "User selected: Skip remediation"
                return 1
                ;;
            3)
                log_message "INFO" "User selected: Exit script"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Function to add mount option to /etc/fstab
add_mount_option() {
    local mount_point="$1"
    local option="$2"
    local fstab="/etc/fstab"

    backup_file "$fstab"

    if ! grep -q "[[:space:]]$mount_point[[:space:]]" "$fstab"; then
        log_message "WARNING" "$mount_point not found in $fstab"
        return 1
    fi

    if grep "[[:space:]]$mount_point[[:space:]]" "$fstab" | grep -q "$option"; then
        log_message "INFO" "Option $option already present for $mount_point"
        return 0
    fi

    # Add option to mount options field
    sed -i "\|[[:space:]]$mount_point[[:space:]]| s/defaults/defaults,$option/" "$fstab"

    if grep "[[:space:]]$mount_point[[:space:]]" "$fstab" | grep -q "$option"; then
        log_message "SUCCESS" "Added $option to $mount_point in $fstab"
        return 0
    else
        log_message "ERROR" "Failed to add $option to $mount_point"
        return 1
    fi
}

# Function to remount with new options
remount_partition() {
    local mount_point="$1"

    if mount -o remount "$mount_point" 2>/dev/null; then
        log_message "SUCCESS" "Remounted $mount_point with updated options"
        return 0
    else
        log_message "WARNING" "Could not remount $mount_point - reboot required"
        return 1
    fi
}

# Main remediation function
main_remediation() {
    log_message "INFO" "Starting remediation: $SCRIPT_NAME"

    set -e
    trap 'log_message "ERROR" "Script failed at line $LINENO"; exit 1' ERR

    local mount_point="/var/tmp"
    local option="noexec"

    # Check if /var/tmp is a separate partition
    if ! check_vartmp_partition; then
        log_message "WARNING" "/var/tmp is not a separate partition"
        log_message "INFO" "CIS Benchmark requires /var/tmp as separate partition"

        # Prompt user for action
        if prompt_user_for_remediation; then
            # User chose to apply remediation
            if create_vartmp_bind_mount; then
                log_message "SUCCESS" "Bind mount created successfully"

                # Verify if noexec is inherited from /tmp
                if mount | grep "on /var/tmp type" | grep -q "noexec"; then
                    log_message "SUCCESS" "/var/tmp now has noexec option (inherited from /tmp)"
                else
                    log_message "WARNING" "/tmp does not have noexec option set"
                    log_message "WARNING" "Consider running remediation for /tmp with noexec option"
                fi

                # Display current mount status
                echo ""
                echo "=========================================================================="
                echo "  Remediation Applied Successfully"
                echo "=========================================================================="
                echo ""
                mount | grep "/var/tmp" || echo "Mount information not available"
                echo ""
                log_message "SUCCESS" "Remediation completed: $SCRIPT_NAME"
                return 0
            else
                log_message "ERROR" "Failed to create bind mount"
                return 1
            fi
        else
            # User chose to skip remediation
            log_message "WARNING" "Remediation skipped by user"
            log_message "WARNING" "System is NOT compliant with CIS Benchmark 1.1.12"
            echo ""
            echo "=========================================================================="
            echo "  Remediation Skipped"
            echo "=========================================================================="
            echo ""
            echo "The system remains non-compliant with CIS Benchmark 1.1.12"
            echo "Manual intervention required to meet compliance requirements"
            echo ""
            return 0
        fi
    fi

    # If /var/tmp IS already a separate partition, just add noexec
    log_message "INFO" "/var/tmp is already a separate partition"

    # Check current mount options
    local current_options=$(mount | grep "on $mount_point type" | sed 's/.*(\(.*\))//')
    log_message "INFO" "Current mount options: $current_options"

    # Check if noexec is already set
    if echo "$current_options" | grep -q "noexec"; then
        log_message "INFO" "$mount_point already has noexec option"
    else
        log_message "INFO" "Adding noexec option to $mount_point"

        if add_mount_option "$mount_point" "$option"; then
            log_message "SUCCESS" "Updated /etc/fstab with noexec"

            if remount_partition "$mount_point"; then
                log_message "SUCCESS" "$mount_point remounted with noexec"
            else
                log_message "WARNING" "Reboot required for changes"
            fi
        else
            log_message "ERROR" "Failed to update /etc/fstab"
            return 1
        fi
    fi

    # Verify configuration
    if mount | grep "on $mount_point type" | grep -q "noexec"; then
        log_message "SUCCESS" "Verified: $mount_point has noexec option"
    else
        log_message "WARNING" "noexec not active yet - reboot required"
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
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        log_message "ERROR" "Script must be run as root"
        exit 1
    fi

    main_remediation
    exit $?
fi
