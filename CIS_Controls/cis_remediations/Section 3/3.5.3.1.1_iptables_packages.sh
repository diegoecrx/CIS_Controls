"#!/usr/bin/env bash
# 3.5.3.1.1 Ensure iptables packages are installed (CIS Oracle Linux 7)
# Scope: Install iptables and iptables-services packages only (no enable/start actions).
# Verification: rpm -q and iptables/ip6tables binary presence.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.3.1.1""

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

install_pkg() {
  local pkg=""$1""
  if pkg_installed ""$pkg""; then
    return 0
  fi
  if command -v yum >/dev/null 2>&1; then
    yum -y install ""$pkg"" >/dev/null
  elif command -v dnf >/dev/null 2>&1; then
    dnf -y install ""$pkg"" >/dev/null
  else
    echo ""FAIL: Neither yum nor dnf available to install ${pkg} (${CONTROL_ID})""
    exit 1
  fi
}

verify_installed() {
  local ok=1
  pkg_installed iptables || ok=0
  pkg_installed iptables-services || ok=0
  # Helpful binary checks (should be provided by iptables)
  command -v iptables   >/dev/null 2>&1 || ok=0
  command -v ip6tables  >/dev/null 2>&1 || ok=0
  return $ok
}

main() {
  require_root

  install_pkg iptables
  install_pkg iptables-services
  # No service state changes (enable/start) performed here by design.

  if verify_installed; then
    echo ""OK: iptables and iptables-services are installed (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: iptables and/or iptables-services not installed correctly (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
