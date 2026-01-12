#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.6 Ensure no unconfined services exist
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.5.1.6 - Check for unconfined services ==="

echo "Checking for unconfined services..."
UNCONFINED=$(ps -eZ | grep unconfined_service_t | awk -F: '{ print $NF }')

if [ -z "$UNCONFINED" ]; then
    echo "PASS: No unconfined services found"
else
    echo "FAIL: The following unconfined services were found:"
    ps -eZ | grep unconfined_service_t
    echo ""
    echo "Investigate these processes and either:"
    echo " - Assign an existing SELinux security context"
    echo " - Build a custom policy for them"
fi
