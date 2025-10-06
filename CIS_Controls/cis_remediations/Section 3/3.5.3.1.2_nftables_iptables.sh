"#!/usr/bin/env bash
# 3.5.3.1.2 Ensure nftables is not installed with iptables (CIS Oracle Linux 7)
# Actions:
#   - Stop and mask nftables.service if present (defensive)
#   - Remove nftables package
# Verification:
#   - rpm -q nftables => not installed
#   - nftables.service => not active (and masked or absent)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.3.1.2""
UNIT=""nftables.service""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() { rpm -q nftables >/dev/null 2>&1; }

service_exists() { systemctl list-unit-files ""${UNIT}"" >/dev/null 2>&1; }

stop_disable_mask_service() {
  if service_exists; then
    systemctl stop ""${UNIT}"" >/dev/null 2>&1 || true
    systemctl disable ""${UNIT}"" >/dev/null 2>&1 || true
    systemctl mask ""${UNIT}"" >/dev/null 2>&1 || true
  fi
}

remove_pkg() {
  if pkg_installed; then
    if command -v yum >/dev/null 2>&1; then
      yum -y remove nftables >/dev/null
    elif command -v dnf >/dev/null 2>&1; then
      dnf -y remove nftables >/dev/null
    else
      echo ""FAIL: Neither yum nor dnf available to remove nftables (${CONTROL_ID})""
      exit 1
    fi
  fi
}

verify_absent() {
  local ok=1
  # package must be gone
  if pkg_installed; then ok=0; fi
  # service must not be active/enabled (if unit still lingers)
  if service_exists; then
    [[ ""$(systemctl is-active ""${UNIT}"" 2>/dev/null || true)"" == ""active"" ]] && ok=0
    # Prefer masked (or at least disabled)
    local state; state=""$(systemctl is-enabled ""${UNIT}"" 2>/dev/null || true)""
    if [[ ""$state"" != ""masked"" && ""$state"" != ""disabled"" && ""$state"" != ""static"" && ""$state"" != ""indirect"" && ""$state"" != ""disabled-runtime"" ]]; then
      ok=0
    fi
  fi
  return $ok
}

main() {
  require_root
  stop_disable_mask_service
  remove_pkg

  if verify_absent; then
    echo ""OK: nftables is not installed (and service not active) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables still present or service active (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
