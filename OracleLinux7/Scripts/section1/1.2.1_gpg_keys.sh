#!/bin/bash
# CIS Oracle Linux 7 - 1.2.1 Ensure GPG keys are configured
# Compatible with OCI (Oracle Cloud Infrastructure)
# NOTE: Manual review required

echo "=== CIS 1.2.1 - Ensure GPG keys are configured ==="
echo "NOTE: This is a manual review item. Verify GPG keys match site policy."
echo ""
echo "Current GPG keys:"
rpm -q gpg-pubkey --queryformat '%{name}-%{version}-%{release} --> %{summary}\n'
echo ""
echo "Update GPG keys according to site policy if needed."
