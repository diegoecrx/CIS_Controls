#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.2.5
# Ensure root password is set
# This script provides PRINT ONLY (affects root)

echo "CIS 4.5.2.5 - Checking root password..."
echo "==========================================="
echo ""
echo "[CAUTION] This control affects root authentication."
echo ""
echo "Checking root password status:"
passwd -S root
echo ""
echo "Root should show 'PS' (password set) status, not 'NP' or 'LK'."
echo ""
echo "If root password is not set, use:"
echo "  passwd root"
echo ""
echo "CIS 4.5.2.5 - Manual review required."