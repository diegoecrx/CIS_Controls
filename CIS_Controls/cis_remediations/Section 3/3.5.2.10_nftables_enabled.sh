"#!/usr/bin/env bash
# 3.5.2.10 Ensure nftables service is enabled (CIS Oracle Linux 7)
# Actions:
#   - Verify nftables installed
#   - Unmask nftables.service (if masked)
#   - Enable nftables.service (do not start; start is covered elsewhere)
# Verification:
#   - systemctl is-enabled nftables == enabled
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.10""
UNIT=""nftables.service""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

nft_installed() {
  rpm -q nftables >/dev/null 2>&1 || command -v nft >/dev/null 2>&1
}

unit_exists() {
  systemctl list-unit-files ""${UNIT}"" >/dev/null 2>&1
}

ensure_installed_or_fail() {
  if ! nft_installed; then
    echo ""FAIL: nftables not installed (run CIS 3.5.2.1 first) (${CONTROL_ID})""
    exit 1
  fi
}

unmask_enable() {
  # Unmask if needed
  if systemctl is-enabled ""${UNIT}"" 2>/dev/null | grep -q '^masked$'; then
    systemctl unmask ""${UNIT}"" >/dev/null
  fi
  # Enable (idempotent)
  systemctl daemon-reload >/dev/null
  systemctl enable ""${UNIT}"" >/dev/null
}

verify_enabled() {
  local ok=1
  unit_exists || ok=0
  [[ ""$(systemctl is-enabled ""${UNIT}"" 2>/dev/null || true)"" == ""enabled"" ]] || ok=0
  return $ok
}

main() {
  require_root
  ensure_installed_or_fail

  if ! unit_exists; then
    echo ""FAIL: ${UNIT} unit file not found (verify nftables package) (${CONTROL_ID})""
    exit 1
  fi

  unmask_enable

  if verify_enabled; then
    echo ""OK: nftables service is enabled (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables service is not enabled (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
