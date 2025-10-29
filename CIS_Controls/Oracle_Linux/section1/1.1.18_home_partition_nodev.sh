#!/bin/bash

###############################################################################
# CIS Oracle Linux 7 Benchmark
# 1.1.18_home_partition_nodev.sh
# CIS Control - 1.1.18_home_partition_nodev.sh
#
# DEFINITIVE VERSION - Implements nodev option for /home
###############################################################################

SCRIPT_NAME="1.1.18_home_partition_nodev.sh"
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

# Check if /home is a separate partition
check_home_partition() {
    if mount | grep -q " on /home "; then
        log_message "INFO" "/home is a separate partition"
        return 0
    else
        log_message "WARNING" "/home is not a separate partition"
        return 1
    fi
}

# Create /home as separate partition with user guidance
create_home_partition_interactive() {
    echo ""
    echo "=========================================================================="
    echo "  Creating Separate /home Partition - Manual Steps Required"
    echo "=========================================================================="
    echo ""
    echo "IMPORTANT: This process requires system downtime and careful execution."
    echo ""
    echo "Step-by-step guide:"
    echo ""
    echo "1. Check available disk space:"
    echo "   # df -h"
    echo "   # lsblk"
    echo ""
    echo "2. Create a new partition or LVM volume:"
    echo "   Using LVM (recommended):"
    echo "   # lvcreate -L 20G -n home_lv vg_name"
    echo "   # mkfs.ext4 /dev/vg_name/home_lv"
    echo ""
    echo "   Using fdisk/parted:"
    echo "   # fdisk /dev/sdX  (create new partition)"
    echo "   # mkfs.ext4 /dev/sdXN"
    echo ""
    echo "3. Backup current /home contents:"
    echo "   # mkdir -p /tmp/home_backup"
    echo "   # rsync -av /home/ /tmp/home_backup/"
    echo ""
    echo "4. Add entry to /etc/fstab:"
    echo "   /dev/vg_name/home_lv  /home  ext4  defaults,nodev  0  2"
    echo ""
    echo "5. Mount the new partition:"
    echo "   # mount /home"
    echo ""
    echo "6. Restore contents:"
    echo "   # rsync -av /tmp/home_backup/ /home/"
    echo ""
    echo "7. Verify and reboot:"
    echo "   # mount | grep /home"
    echo "   # reboot"
    echo ""
    echo "=========================================================================="
    echo ""

    log_message "INFO" "Displayed manual partition creation instructions"
    return 0
}

# Force add /home entry to fstab even if not separate
force_home_fstab_entry() {
    local fstab="/etc/fstab"

    log_message "WARNING" "Force option selected - adding /home entry without separate partition"
    log_message "WARNING" "This creates a placeholder entry for future use"

    backup_file "$fstab"

    # Check if /home entry already exists
    if grep -q "[[:space:]]/home[[:space:]]" "$fstab"; then
        log_message "INFO" "/home entry already exists in fstab"

        # Add nodev if not present
        if ! grep "[[:space:]]/home[[:space:]]" "$fstab" | grep -q "nodev"; then
            sed -i "/[[:space:]]\/home[[:space:]]/ s/defaults/defaults,nodev/" "$fstab"
            log_message "SUCCESS" "Added nodev to existing /home entry"
        fi
    else
        # Add commented placeholder entry
        echo "# /home partition - uncomment and configure when creating separate partition" >> "$fstab"
        echo "# /dev/mapper/vg-home  /home  ext4  defaults,nodev  0  2" >> "$fstab"
        log_message "INFO" "Added commented placeholder for /home in fstab"
    fi

    echo ""
    echo "=========================================================================="
    echo "  Force Option Applied"
    echo "=========================================================================="
    echo ""
    echo "A placeholder entry has been added to /etc/fstab."
    echo "When you create a separate /home partition:"
    echo "  1. Edit /etc/fstab"
    echo "  2. Uncomment and configure the /home entry"
    echo "  3. Ensure 'nodev' option is present"
    echo "  4. Mount and verify: mount /home"
    echo ""
    echo "Current /etc/fstab /home entry:"
    grep -A1 "home" "$fstab" | tail -2
    echo ""
    echo "=========================================================================="
    echo ""

    return 0
}

# Add mount option to /etc/fstab
add_mount_option() {
    local mount_point="$1"
    local option="$2"
    local fstab="/etc/fstab"

    backup_file "$fstab"

    # Check if mount point exists in fstab
    if ! grep -q "[[:space:]]$mount_point[[:space:]]" "$fstab"; then
        log_message "ERROR" "$mount_point not found in $fstab"
        return 1
    fi

    # Check if option already present
    if grep "[[:space:]]$mount_point[[:space:]]" "$fstab" | grep -q "$option"; then
        log_message "INFO" "Option $option already present for $mount_point"
        return 0
    fi

    # Add the option - handle different formats
    if grep "[[:space:]]$mount_point[[:space:]]" "$fstab" | grep -q "defaults"; then
        sed -i "/[[:space:]]$(echo $mount_point | sed 's/\//\\\//g')[[:space:]]/ s/defaults/defaults,$option/" "$fstab"
    else
        # Append to fourth field
        sed -i "/[[:space:]]$(echo $mount_point | sed 's/\//\\\//g')[[:space:]]/ s/\([[:space:]]\)\([^[:space:]]\+[[:space:]]\)\([^[:space:]]\+[[:space:]]\)\([^[:space:],]\+\)/\1\2\3\4,$option/" "$fstab"
    fi

    # Verify
    if grep "[[:space:]]$mount_point[[:space:]]" "$fstab" | grep -q "$option"; then
        log_message "SUCCESS" "Added $option to $mount_point in $fstab"
        return 0
    else
        log_message "ERROR" "Failed to add $option to $fstab"
        return 1
    fi
}

# Remount partition
remount_partition() {
    local mount_point="$1"
    local option="$2"

    log_message "INFO" "Attempting to remount $mount_point with $option"

    if mount -o "remount,$option" "$mount_point" 2>/dev/null; then
        log_message "SUCCESS" "Remounted $mount_point with $option option"
        return 0
    else
        log_message "WARNING" "Could not remount $mount_point immediately"
        return 1
    fi
}

# Prompt user with three options
prompt_user() {
    echo ""
    echo "=========================================================================="
    echo "  CIS Benchmark 1.1.18 - /home Partition Not Found"
    echo "=========================================================================="
    echo ""
    echo "Issue: /home is not configured as a separate partition"
    echo ""
    echo "CIS Benchmark recommends /home as a separate partition with 'nodev'"
    echo "option to prevent device files from being created in user home directories."
    echo ""
    echo "Remediation Actions:"
    echo ""
    echo "Per CIS Benchmark:"
    echo "  'For existing /home partitions, edit the /etc/fstab file and add nodev"
    echo "   to the fourth field (mounting options) of the /home entry."
    echo "   Run: mount -o remount,nodev /home'"
    echo ""
    echo "Additional Information:"
    echo "  The actions in this recommendation refer to the /home partition,"
    echo "  which is the default user partition. If you have created other user"
    echo "  partitions, apply these steps to those partitions as well."
    echo ""
    echo "This is a LEVEL 2 requirement (recommended but not mandatory)."
    echo ""
    echo "=========================================================================="
    echo ""
    echo "Options:"
    echo ""
    echo "  1) Skip this check (remain non-compliant with Level 2)"
    echo "  2) Show manual instructions for creating /home partition"
    echo "  3) Force: Add placeholder entry to /etc/fstab for future use"
    echo "  4) Exit script"
    echo ""

    while true; do
        read -p "Choice [1-4]: " choice
        case $choice in
            1) 
                log_message "INFO" "User chose to skip /home partition requirement"
                return 1
                ;;
            2)
                create_home_partition_interactive
                log_message "INFO" "Displayed manual partition creation steps"
                return 1
                ;;
            3)
                force_home_fstab_entry
                log_message "INFO" "User chose force option - placeholder added"
                return 2
                ;;
            4)
                log_message "INFO" "User chose to exit"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
}

# Main function
main_remediation() {
    log_message "INFO" "Starting remediation: $SCRIPT_NAME"

    local mount_point="/home"
    local option="nodev"
    local reboot_required=0

    # Check if /home is a separate partition
    if ! check_home_partition; then
        # /home is not separate
        log_message "WARNING" "/home is not a separate partition"
        log_message "INFO" "CIS Benchmark Level 2 recommends /home as separate partition"

        local user_choice
        prompt_user
        user_choice=$?

        if [ $user_choice -eq 1 ]; then
            # User skipped
            log_message "WARNING" "Skipping /home partition configuration"
            log_message "WARNING" "System is non-compliant with CIS 1.1.18 (Level 2)"

            echo ""
            echo "=========================================================================="
            echo "  Remediation Skipped"
            echo "=========================================================================="
            echo ""
            echo "System remains non-compliant with CIS Benchmark 1.1.18"
            echo "This is a Level 2 requirement - not mandatory for basic compliance"
            echo ""

            return 0
        elif [ $user_choice -eq 2 ]; then
            # Force option was applied
            log_message "SUCCESS" "Placeholder entry added to /etc/fstab"
            return 0
        fi
    else
        # /home is a separate partition
        log_message "SUCCESS" "/home is mounted as a separate partition"

        # Check current mount options
        local current_options=$(mount | grep " on $mount_point " | sed 's/.*(\(.*\))//')
        log_message "INFO" "Current mount options for $mount_point: $current_options"

        # Check if nodev already present
        if echo "$current_options" | grep -q "$option"; then
            log_message "SUCCESS" "$mount_point already has $option option"
            echo ""
            echo "=========================================================================="
            echo "  ? CIS 1.1.18 COMPLIANT"
            echo "=========================================================================="
            echo ""
            echo "/home is mounted with nodev option"
            mount | grep " on /home "
            echo ""
            return 0
        fi

        # Add nodev option
        log_message "INFO" "Adding $option option to $mount_point"

        if add_mount_option "$mount_point" "$option"; then
            log_message "SUCCESS" "Updated /etc/fstab with $option option"

            # Try to remount per CIS recommendation
            if remount_partition "$mount_point" "$option"; then
                log_message "SUCCESS" "Changes applied immediately per CIS guidance"
            else
                log_message "WARNING" "Reboot required to apply changes"
                reboot_required=1
            fi
        else
            log_message "ERROR" "Failed to update /etc/fstab"
            return 1
        fi
    fi

    # Display current configuration
    echo ""
    echo "=========================================================================="
    echo "  Current Configuration"
    echo "=========================================================================="
    if mount | grep -q " on /home "; then
        mount | grep " on /home "
    else
        echo "/home is not separately mounted"
    fi
    echo ""
    echo "  /etc/fstab entry for /home:"
    grep "/home" /etc/fstab 2>/dev/null || echo "  No /home entry found"
    echo "=========================================================================="
    echo ""

    # Check for other user partitions
    echo "Checking for other user partitions (per CIS guidance)..."
    if mount | grep -E " on /home/[^[:space:]]+ "; then
        echo ""
        echo "??  Additional user partitions detected:"
        mount | grep -E " on /home/[^[:space:]]+ "
        echo ""
        echo "CIS Benchmark recommends applying nodev to these partitions as well."
        log_message "WARNING" "Additional user partitions detected - manual review needed"
    else
        echo "No additional user partitions detected."
    fi
    echo ""

    # Final status
    if [ $reboot_required -eq 1 ]; then
        echo "??  REBOOT REQUIRED"
        echo ""
        echo "Changes have been made to /etc/fstab."
        echo "Per CIS Benchmark: Run 'mount -o remount,nodev /home' after reboot."
        echo ""
        log_message "WARNING" "REBOOT REQUIRED for changes to take effect"
    else
        if mount | grep " on /home " | grep -q "$option"; then
            echo "? SUCCESS: /home has nodev option - CIS 1.1.18 COMPLIANT"
            log_message "SUCCESS" "CIS 1.1.18 COMPLIANT - /home has nodev"
        elif [ ! -d /home ] || ! mount | grep -q " on /home "; then
            echo "?  /home not separately mounted - placeholder entry added for future use"
            log_message "INFO" "Placeholder entry configured for future /home partition"
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
