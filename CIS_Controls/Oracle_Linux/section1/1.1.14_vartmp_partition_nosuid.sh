#!/bin/bash

###############################################################################
# CIS Oracle Linux 7 Benchmark
# 1.1.14_vartmp_partition_nosuid.sh
# CIS Control - 1.1.14_vartmp_partition_nosuid.sh
#
# DEFINITIVE VERSION - Implements nosuid option for /var/tmp
###############################################################################

SCRIPT_NAME="1.1.14_vartmp_partition_nosuid.sh"
BACKUP_DIR="/tmp/cis_backup"
LOG_FILE="/var/log/cis_remediation.log"
ERROR_LOG="/var/log/cis_error_analysis.log"

# Create backup directory
mkdir -p "$BACKUP_DIR" 2>/dev/null || {
    echo "Failed to create backup directory: $BACKUP_DIR"
    exit 1
}

# Logging function
log_message() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] [$SCRIPT_NAME] $message" | tee -a "$LOG_FILE"

    if [ "$level" = "ERROR" ]; then
        echo "[$timestamp] [$SCRIPT_NAME] ERROR: $message" >> "$ERROR_LOG"
    fi
}

# Backup function
backup_file() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        log_message "WARNING" "File does not exist for backup: $file_path"
        return 1
    fi

    local backup_name="$(basename "$file_path").$(date +%Y%m%d_%H%M%S).backup"

    if cp "$file_path" "$BACKUP_DIR/$backup_name" 2>/dev/null; then
        log_message "INFO" "Backed up $file_path to $BACKUP_DIR/$backup_name"
        return 0
    else
        log_message "ERROR" "Failed to backup $file_path"
        return 1
    fi
}

# Check if /var/tmp is mounted
check_vartmp_partition() {
    if mount | grep -q " on /var/tmp "; then
        log_message "INFO" "/var/tmp is mounted separately"
        return 0
    else
        log_message "WARNING" "/var/tmp is not a separate partition"
        return 1
    fi
}

# Check if it's a bind mount
is_bind_mount() {
    if mount | grep "/var/tmp" | grep -q "bind"; then
        return 0
    fi
    if grep -q "^/tmp[[:space:]]*/var/tmp.*bind" /etc/fstab 2>/dev/null; then
        return 0
    fi
    return 1
}

# Create bind mount
create_vartmp_bind_mount() {
    log_message "INFO" "Creating bind mount for /var/tmp to /tmp"

    # Backup contents
    local backup_path="$BACKUP_DIR/var_tmp_contents_$(date +%Y%m%d_%H%M%S)"
    if [ -d /var/tmp ] && [ "$(ls -A /var/tmp 2>/dev/null)" ]; then
        log_message "INFO" "Backing up /var/tmp contents"
        mkdir -p "$backup_path"
        cp -a /var/tmp/* "$backup_path/" 2>/dev/null || true
    fi

    # Clear directory
    find /var/tmp -mindepth 1 -delete 2>/dev/null || true

    # Create bind mount
    if mount --bind /tmp /var/tmp; then
        log_message "SUCCESS" "Bind mount created"
    else
        log_message "ERROR" "Failed to create bind mount"
        return 1
    fi

    # Add to fstab
    backup_file "/etc/fstab"

    if ! grep -q "^/tmp[[:space:]]*/var/tmp.*bind" /etc/fstab; then
        echo "/tmp /var/tmp none bind 0 0" >> /etc/fstab
        log_message "SUCCESS" "Added bind mount to /etc/fstab"
    fi

    # Restore contents
    if [ -d "$backup_path" ] && [ "$(ls -A $backup_path 2>/dev/null)" ]; then
        cp -a "$backup_path"/* /var/tmp/ 2>/dev/null || true
    fi

    return 0
}

# Ensure /tmp has nosuid
ensure_tmp_has_nosuid() {
    log_message "INFO" "Ensuring /tmp has nosuid option"

    # Check current mount
    if mount | grep " on /tmp " | grep -q "nosuid"; then
        log_message "SUCCESS" "/tmp already has nosuid option"
        return 0
    fi

    log_message "INFO" "/tmp does not have nosuid, will configure it"

    backup_file "/etc/fstab"

    # Check what type of /tmp we have
    local tmp_device=$(mount | grep " on /tmp " | awk '{print $1}')

    if [ -z "$tmp_device" ]; then
        # /tmp not separately mounted
        log_message "INFO" "/tmp is not separately mounted (uses root filesystem)"

        # Check if tmpfs entry already exists
        if ! grep -q "[[:space:]]/tmp[[:space:]]" /etc/fstab; then
            echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec,size=2G 0 0" >> /etc/fstab
            log_message "SUCCESS" "Added tmpfs /tmp entry to /etc/fstab"
        else
            # Entry exists, ensure it has nosuid
            if ! grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep -q "nosuid"; then
                sed -i '/[[:space:]]\/tmp[[:space:]]/ s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
                log_message "SUCCESS" "Added security options to existing /tmp entry"
            fi
        fi

        log_message "WARNING" "Reboot required for /tmp changes to take effect"
        return 2  # Reboot required
    else
        # /tmp is separately mounted
        log_message "INFO" "/tmp is mounted from: $tmp_device"

        # Update fstab
        if grep -q "$tmp_device.*[[:space:]]/tmp[[:space:]]" /etc/fstab; then
            if ! grep "$tmp_device.*[[:space:]]/tmp[[:space:]]" /etc/fstab | grep -q "nosuid"; then
                sed -i "\\|$tmp_device.*[[:space:]]/tmp[[:space:]]| s/defaults/defaults,nodev,nosuid,noexec/" /etc/fstab
                log_message "SUCCESS" "Updated /tmp entry in /etc/fstab"
            fi
        elif grep -q "tmpfs[[:space:]]*/tmp" /etc/fstab; then
            if ! grep "tmpfs[[:space:]]*/tmp" /etc/fstab | grep -q "nosuid"; then
                sed -i '/tmpfs[[:space:]]*\/tmp/ s/defaults/defaults,nodev,nosuid,noexec/' /etc/fstab
                log_message "SUCCESS" "Updated tmpfs /tmp entry"
            fi
        fi

        # Try to remount
        if mount -o remount,nodev,nosuid,noexec /tmp 2>/dev/null; then
            log_message "SUCCESS" "Remounted /tmp with security options"
            return 0
        else
            log_message "WARNING" "Could not remount /tmp - reboot recommended"
            return 2
        fi
    fi
}

# Prompt user
prompt_user() {
    echo ""
    echo "=========================================================================="
    echo "  CIS Benchmark 1.1.14 - /var/tmp nosuid Requirement"
    echo "=========================================================================="
    echo ""
    echo "Issue: /var/tmp is not configured as a separate partition"
    echo ""
    echo "The 'nosuid' option prevents setuid/setgid bits from being honored,"
    echo "protecting against privilege escalation attacks."
    echo ""
    echo "Remediation: Create bind mount from /tmp to /var/tmp"
    echo ""
    echo "Options:"
    echo "  1) Apply remediation (recommended)"
    echo "  2) Skip (remain non-compliant)"
    echo "  3) Exit"
    echo ""

    while true; do
        read -p "Choice [1-3]: " choice
        case $choice in
            1) return 0 ;;
            2) return 1 ;;
            3) exit 0 ;;
            *) echo "Invalid choice" ;;
        esac
    done
}

# Main function
main_remediation() {
    log_message "INFO" "Starting remediation: $SCRIPT_NAME"

    local reboot_required=0

    # Check if /var/tmp is mounted
    if ! check_vartmp_partition; then
        # Not mounted - need bind mount
        if prompt_user; then
            ensure_tmp_has_nosuid
            local tmp_result=$?
            if [ $tmp_result -eq 2 ]; then
                reboot_required=1
            fi

            create_vartmp_bind_mount

            if [ $reboot_required -eq 0 ]; then
                umount /var/tmp 2>/dev/null || true
                mount /var/tmp
                log_message "SUCCESS" "Bind mount active"
            fi
        else
            log_message "WARNING" "Remediation skipped by user"
            return 0
        fi
    else
        # /var/tmp is mounted
        if is_bind_mount; then
            log_message "INFO" "/var/tmp is a bind mount to /tmp"

            # Ensure /tmp has nosuid
            ensure_tmp_has_nosuid
            local tmp_result=$?
            if [ $tmp_result -eq 2 ]; then
                reboot_required=1
            fi

            if [ $reboot_required -eq 0 ]; then
                # Remount to inherit
                umount /var/tmp 2>/dev/null || true
                mount /var/tmp 2>/dev/null || true

                if mount | grep " on /var/tmp " | grep -q "nosuid"; then
                    log_message "SUCCESS" "/var/tmp now has nosuid (inherited from /tmp)"
                else
                    log_message "WARNING" "Changes will take effect after reboot"
                    reboot_required=1
                fi
            fi
        else
            # Regular partition
            log_message "INFO" "/var/tmp is a regular partition"

            if mount | grep " on /var/tmp " | grep -q "nosuid"; then
                log_message "SUCCESS" "/var/tmp already has nosuid"
            else
                backup_file "/etc/fstab"

                # Add nosuid to fstab
                sed -i '/[[:space:]]\/var\/tmp[[:space:]]/ s/defaults/defaults,nosuid/' /etc/fstab

                if mount -o remount,nosuid /var/tmp 2>/dev/null; then
                    log_message "SUCCESS" "Remounted /var/tmp with nosuid"
                else
                    log_message "WARNING" "Reboot required"
                    reboot_required=1
                fi
            fi
        fi
    fi

    # Display results
    echo ""
    echo "=========================================================================="
    echo "  Current Configuration"
    echo "=========================================================================="
    mount | grep -E " on /tmp | on /var/tmp " || echo "Not separately mounted"
    echo ""
    echo "  /etc/fstab entries:"
    grep -E "^tmpfs.*tmp|^/tmp|/var/tmp" /etc/fstab 2>/dev/null || echo "  No /tmp or /var/tmp entries"
    echo "=========================================================================="
    echo ""

    if [ $reboot_required -eq 1 ]; then
        echo "??  REBOOT REQUIRED"
        echo ""
        echo "Changes have been made to /etc/fstab but cannot be applied immediately."
        echo "Please reboot the system for changes to take effect."
        echo ""
        log_message "WARNING" "REBOOT REQUIRED for changes to take effect"
    else
        if mount | grep " on /var/tmp " | grep -q "nosuid"; then
            echo "? SUCCESS: /var/tmp has nosuid option - CIS 1.1.14 COMPLIANT"
            log_message "SUCCESS" "CIS 1.1.14 COMPLIANT - /var/tmp has nosuid"
        else
            echo "??  WARNING: nosuid not yet active"
            log_message "WARNING" "nosuid configuration incomplete"
        fi
    fi

    log_message "SUCCESS" "Remediation completed: $SCRIPT_NAME"
    return 0
}

# Execute
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Must run as root"
        exit 1
    fi

    main_remediation
    exit $?
fi
