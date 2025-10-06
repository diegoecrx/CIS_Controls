"#!/usr/bin/env bash
# 3.5.1.4 Ensure firewalld service enabled and running (CIS Oracle Linux 7)
# Actions:
#   - Ensure firewalld package present (install if missing)
#   - Unmask firewalld
#   - Enable and start firewalld (systemctl --now enable firewalld)
# Verification:
#   - systemctl is-enabled firewalld == enabled
#   - systemctl is-active firewalld == active
#   - firewall-cmd --state == running
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.4""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

pkg_installed() {
  rpm -q firewalld >/dev/null 2>&1
}

ensure_installed() {
  if pkg_installed; then
    return 0
  fi
  if command -v yum >/dev/null 2>&1; then
    yum -y install firewalld >/dev/null
  elif command -v dnf >/dev/null 2>&1; then
    dnf -y install firewalld >/dev/null
  else
    echo ""FAIL: Neither yum nor dnf available to install firewalld (${CONTROL_ID})""
    exit 1
  fi
}

unmask_enable_start() {
  # Unmask if masked
  if systemctl is-enabled firewalld 2>/dev/null | grep -q '^masked$'; then
    systemctl unmask firewalld >/dev/null
  fi
  # Enable and start now
  systemctl --now enable firewalld >/dev/null
  # Defensive: reload daemon and ensure running
  systemctl daemon-reload >/dev/null
  systemctl restart firewalld >/dev/null || true
}

verify_state() {
  local ok=1
  # Enabled?
  [[ ""$(systemctl is-enabled firewalld 2>/dev/null || true)"" == ""enabled"" ]] || ok=0
  # Active?
  [[ ""$(systemctl is-active firewalld 2>/dev/null || true)"" == ""active"" ]] || ok=0
  # firewall-cmd reports running?
  if command -v firewall-cmd >/dev/null 2>&1; then
    [[ ""$(firewall-cmd --state 2>/dev/null || true)"" == ""running"" ]] || ok=0
  else
    ok=0
  fi
  return $ok
}

main() {
  require_root
  ensure_installed
  unmask_enable_start

  if verify_state; then
    echo ""OK: firewalld is enabled and running (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: firewalld not enabled and running (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
