"#!/usr/bin/env bash
# 3.5.1.3 Ensure nftables either not installed or masked with firewalld (CIS Oracle Linux 7)
# Default: remove nftables package. To keep installed but masked, export NFTABLES_ACTION=mask
#   - Removal path: yum -y remove nftables
#   - Mask path: systemctl --now mask nftables
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.3""
ACTION=""${NFTABLES_ACTION:-remove}""  # acceptable: remove | mask

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  rpm -q nftables >/dev/null 2>&1
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

service_exists() {
  systemctl list-unit-files nftables.service >/dev/null 2>&1
}

mask_service() {
  # Stop and mask if service exists (unit may not exist if package absent)
  if service_exists; then
    systemctl stop nftables.service >/dev/null 2>&1 || true
    systemctl disable nftables.service >/dev/null 2>&1 || true
    systemctl mask nftables.service >/dev/null 2>&1 || true
  fi
}

verify() {
  # Pass if EITHER condition is true:
  # 1) package not installed, OR
  # 2) service exists AND is masked and not active
  if ! pkg_installed; then
    return 0
  fi

  # Package installed: then it must be masked and inactive
  if service_exists; then
    local active enabled
    active=""$(systemctl is-active nftables.service 2>/dev/null || true)""
    enabled=""$(systemctl is-enabled nftables.service 2>/dev/null || true)""
    [[ ""$active"" != ""active"" ]] && echo >/dev/null
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
      # Prefer removal outright
      mask_service   # defensive: in case unit lingers
      remove_pkg
      ;;
    mask)
      mask_service
      ;;
    *)
      echo ""FAIL: Invalid NFTABLES_ACTION='$ACTION' (use 'remove' or 'mask') (${CONTROL_ID})""
      exit 1
      ;;
  esac

  if verify; then
    echo ""OK: nftables is absent or masked (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables still installed and not masked (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
