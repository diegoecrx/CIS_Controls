"#!/usr/bin/env bash
# 3.5.3.1.3 Ensure firewalld is either not installed or masked with iptables (CIS Oracle Linux 7)
# Default action: remove firewalld. To keep installed but masked, export FIREWALLD_ACTION=mask
#   - Removal path: yum -y remove firewalld
#   - Mask path: systemctl --now mask firewalld
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.3.1.3""
ACTION=""${FIREWALLD_ACTION:-remove}""  # acceptable: remove | mask
UNIT=""firewalld.service""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  rpm -q firewalld >/dev/null 2>&1
}

service_exists() {
  systemctl list-unit-files ""${UNIT}"" >/dev/null 2>&1
}

mask_service() {
  if service_exists; then
    systemctl stop ""${UNIT}"" >/dev/null 2>&1 || true
    systemctl disable ""${UNIT}"" >/dev/null 2>&1 || true
    systemctl mask ""${UNIT}"" >/dev/null 2>&1 || true
  fi
}

remove_pkg() {
  if pkg_installed; then
    # defensively stop/mask before removal
    mask_service
    if command -v yum >/dev/null 2>&1; then
      yum -y remove firewalld >/dev/null
    elif command -v dnf >/dev/null 2>&1; then
      dnf -y remove firewalld >/dev/null
    else
      echo ""FAIL: Neither yum nor dnf available to remove firewalld (${CONTROL_ID})""
      exit 1
    fi
  fi
}

verify() {
  # Pass if EITHER condition is true:
  # 1) package not installed, OR
  # 2) service exists AND is masked and not active
  if ! pkg_installed; then
    return 0
  fi
  if service_exists; then
    local active enabled
    active=""$(systemctl is-active ""${UNIT}"" 2>/dev/null || true)""
    enabled=""$(systemctl is-enabled ""${UNIT}"" 2>/dev/null || true)""
    if [[ ""$enabled"" == ""masked"" && ""$active"" != ""active"" ]]; then
      return 0
    fi
  fi
  return 1
}

main() {
  require_root

  case ""$ACTION"" in
    remove)
      remove_pkg
      ;;
    mask)
      mask_service
      ;;
    *)
      echo ""FAIL: Invalid FIREWALLD_ACTION='$ACTION' (use 'remove' or 'mask') (${CONTROL_ID})""
      exit 1
      ;;
  esac

  if verify; then
    echo ""OK: firewalld is absent or masked when using iptables (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: firewalld still installed and not masked (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
