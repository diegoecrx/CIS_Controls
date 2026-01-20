#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.2.8
# Ensure root path integrity
# This script audits and fixes root PATH issues

echo "CIS 6.2.8 - Ensuring root PATH integrity..."

RPCV="$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)"
echo "Root PATH: $RPCV"
echo ""

found_issue=0

# Check for empty directory in path (::)
if echo "$RPCV" | grep -q "::"; then
    echo " - ISSUE: Empty directory in PATH (::)"
    found_issue=1
fi

# Check for trailing colon
if echo "$RPCV" | grep -q ":$"; then
    echo " - ISSUE: Trailing colon in PATH"
    found_issue=1
fi

# Check for current directory (.)
if echo "$RPCV" | grep -q -E "(^:|:)(\.)(:|$)"; then
    echo " - ISSUE: Current working directory (.) in PATH"
    found_issue=1
fi

# Check each directory in PATH and fix issues
echo "$RPCV" | tr ':' '\n' | while read dir; do
    if [ -n "$dir" ] && [ "$dir" != "." ]; then
        if [ ! -d "$dir" ]; then
            echo " - ISSUE: $dir is not a directory - creating it"
            mkdir -p "$dir"
            chmod 755 "$dir"
            chown root:root "$dir"
        else
            owner="$(stat -c %U "$dir")"
            perms="$(stat -c %a "$dir")"
            
            if [ "$owner" != "root" ]; then
                echo " - ISSUE: $dir is not owned by root - fixing"
                chown root "$dir"
            fi
            
            # Check group write permission (3rd digit)
            if [ $(echo "$perms" | cut -c2) -gt 5 ]; then
                echo " - ISSUE: $dir has group write permission - fixing"
                chmod g-w "$dir"
            fi
            
            # Check other write permission (4th digit, or 3rd for 3-digit perms)
            other_perm=$(echo "$perms" | rev | cut -c1)
            if [ "$other_perm" -gt 5 ]; then
                echo " - ISSUE: $dir has other write permission - fixing"
                chmod o-w "$dir"
            fi
        fi
    fi
done

# Handle /root/bin specifically if in PATH
if echo "$RPCV" | grep -q "/root/bin"; then
    if [ ! -d /root/bin ]; then
        echo " - Creating /root/bin directory"
        mkdir -p /root/bin
        chmod 755 /root/bin
        chown root:root /root/bin
    fi
fi

echo ""
echo "CIS 6.2.8 remediation complete."
