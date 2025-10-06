"#!/usr/bin/env bash
# 3.5.1.2 Ensure iptables-services not installed with firewalld (CIS Oracle Linux 7)
# Actions:
#   - Stop iptables/ip6tables services if present
#   - Disable & mask those services (defensive)
#   - Remove iptables-services package
# Verification:
#   - rpm -q iptables-services => not installed
#   - iptables/ip6tables services => not active (and masked or absent)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.2""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  local pkg=""$1""
  rpm -q ""$pkg"" >/dev/null 2>&1
}

remove_pkg() {
  local pkg=""$1""
  if pkg_installed ""$pkg""; then
    if command -v yum >/dev/null 2>&1; then
      yum -y remove ""$pkg"" >/dev/null
    elif command -v dnf >/dev/null 2>&1; then
      dnf -y remove ""$pkg"" >/dev/null
    else
      echo ""FAIL: Neither yum nor dnf available to remove ${pkg} (${CONTROL_ID})""
      exit 1
    fi
  fi
}

service_exists() {
  local svc=""$1""
  systemctl list-unit-files ""${svc}.service"" >/dev/null 2>&1
}

stop_disable_mask_service() {
  local svc=""$1""
  if service_exists ""$svc""; then
    systemctl stop ""${svc}.service"" >/dev/null 2>&1 || true
    systemctl disable ""${svc}.service"" >/dev/null 2>&1 || true
    systemctl mask ""${svc}.service"" >/dev/null 2>&1 || true
  fi
}

verify_services_inactive() {
  local ok=1 s
  for s in iptables ip6tables; do
    if service_exists ""$s""; then
      # Not active?
      if systemctl is-active ""${s}.service"" >/dev/null 2>&1; then
        ok=0
      fi
      # Prefer masked (or at least disabled)
      if ! systemctl is-enabled ""${s}.service"" 2>/dev/null | grep -q masked; then
        # if not masked, ensure disabled
        systemctl is-enabled ""${s}.service"" >/dev/null 2>&1 && ok=0
      fi
    fi
  done
  return $ok
}

main() {
  require_root

  # Stop/disable/mask legacy services if present
  stop_disable_mask_service iptables
  stop_disable_mask_service ip6tables

  # Remove the legacy package if installed
  remove_pkg iptables-services

  FAIL=0
  # Verify package removal
  if pkg_installed iptables-services; then
    FAIL=1
  fi
  # Verify services are not active/enabled
  verify_services_inactive || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: iptables-services absent and legacy services not active (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: iptables-services still present or legacy services active (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
