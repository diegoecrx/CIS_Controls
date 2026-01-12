#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.2.8
# Ensure root path integrity
# NOTE: Audit only - manual remediation required

echo "CIS 6.2.8 - Checking root PATH integrity..."
echo "=============================================================="
echo "NOTE: This script audits the root PATH variable."
echo ""

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

# Check each directory in PATH
echo "$RPCV" | tr ':' '\n' | while read dir; do
    if [ -n "$dir" ] && [ "$dir" != "." ]; then
        if [ ! -d "$dir" ]; then
            echo " - ISSUE: $dir is not a directory"
        elif [ "$(stat -c %U "$dir")" != "root" ]; then
            echo " - ISSUE: $dir is not owned by root"
        elif [ $(stat -c %a "$dir" | cut -c3) -gt 5 ]; then
            echo " - ISSUE: $dir has group write permission"
        elif [ $(stat -c %a "$dir" | cut -c4) -gt 5 ]; then
            echo " - ISSUE: $dir has other write permission"
        fi
    fi
done

if [ $found_issue -eq 0 ]; then
    echo "Root PATH appears to be correctly configured."
fi

echo ""
echo "CIS 6.2.8 audit complete."