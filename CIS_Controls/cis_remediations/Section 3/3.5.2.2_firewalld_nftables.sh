"#!/usr/bin/env bash
# 3.5.2.2 Ensure firewalld is either not installed or masked with nftables (CIS Oracle Linux 7)
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

CONTROL_ID=""CIS 3.5.2.2""
ACTION=""${FIREWALLD_ACTION:-remove}""  # acceptable: remove | mask

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  rpm -q firewalld >/dev/null 2>&1
}

remove_pkg() {
  if pkg_installed; then
    if command -v systemctl >/dev/null 2>&1; then
      systemctl stop firewalld.service >/dev/null 2>&1 || true
      systemctl disable firewalld.service >/dev/null 2>&1 || true
      systemctl mask firewalld.service >/dev/null 2>&1 || true
    fi
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

service_exists() {
  systemctl list-unit-files firewalld.service >/dev/null 2>&1
}

mask_service() {
  if service_exists; then
    systemctl stop firewalld.service >/dev/null 2>&1 || true
    systemctl disable firewalld.service >/dev/null 2>&1 || true
    systemctl mask firewalld.service >/dev/null 2>&1 || true
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
    active=""$(systemctl is-active firewalld.service 2>/dev/null || true)""
    enabled=""$(systemctl is-enabled firewalld.service 2>/dev/null || true)""
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
      mask_service   # defensive in case unit remains until package removal
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
    echo ""OK: firewalld is absent or masked (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: firewalld still installed and not masked (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
