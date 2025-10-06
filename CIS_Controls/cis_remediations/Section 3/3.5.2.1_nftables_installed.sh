"#!/usr/bin/env bash
# 3.5.2.1 Ensure nftables is installed (CIS Oracle Linux 7)
# Scope: Install nftables package only (no enable/start actions).
# Verification: rpm -q and nft binary presence.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.1""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  rpm -q nftables >/dev/null 2>&1
}

install_pkg() {
  if pkg_installed; then
    return 0
  fi
  if command -v yum >/dev/null 2>&1; then
    yum -y install nftables >/dev/null
  elif command -v dnf >/dev/null 2>&1; then
    dnf -y install nftables >/dev/null
  else
    echo ""FAIL: Neither yum nor dnf available to install nftables (${CONTROL_ID})""
    exit 1
  fi
}

verify_installed() {
  local ok=1
  pkg_installed || ok=0
  command -v nft >/dev/null 2>&1 || ok=0
  # Optional: unit file presence if package ships it
  if systemctl list-unit-files nftables.service >/dev/null 2>&1; then
    : # nothing to enforce here
  fi
  return $ok
}

main() {
  require_root
  install_pkg

  if verify_installed; then
    echo ""OK: nftables is installed (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables not installed correctly (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
