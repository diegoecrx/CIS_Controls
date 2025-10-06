"#!/usr/bin/env bash
# 3.5.1.1 Ensure firewalld is installed (CIS Oracle Linux 7)
# Scope: Install firewalld and iptables packages only (no enable/disable/start actions).
# Verification: rpm -q and binary presence.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.1""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  local pkg=""$1""
  rpm -q --whatprovides ""$pkg"" >/dev/null 2>&1 || rpm -q ""$pkg"" >/dev/null 2>&1
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
  pkg_installed firewalld || ok=0
  pkg_installed iptables || ok=0
  # Helpful binary checks
  command -v firewall-cmd >/dev/null 2>&1 || ok=0
  command -v iptables >/dev/null 2>&1 || ok=0
  return $ok
}

main() {
  require_root

  install_pkg firewalld
  install_pkg iptables

  # No service state changes (enable/start) performed here by design.

  if verify_installed; then
    echo ""OK: firewalld and iptables are installed (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: firewalld and/or iptables not installed (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
