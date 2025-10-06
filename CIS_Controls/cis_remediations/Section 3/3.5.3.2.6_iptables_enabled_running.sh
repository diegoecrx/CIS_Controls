#!/usr/bin/env bash
# 3.5.3.2.6 Ensure iptables is enabled and running (CIS Oracle Linux 7)
# Actions:
#   - Ensure iptables-services package present
#   - Unmask iptables.service (if masked)
#   - Enable and start iptables.service (systemctl --now enable iptables)
# Verification:
#   - systemctl is-enabled iptables == enabled
#   - systemctl is-active  iptables == active
#   - "iptables -L" succeeds (sanity check)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.2.6"
UNIT="iptables.service"

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "FAIL: Must run as root (${CONTROL_ID})"
    exit 1
  fi
}

pkg_installed() {
  rpm -q iptables-services >/dev/null 2>&1
}

ensure_installed() {
  if pkg_installed; then
    return 0
  fi
  if command -v yum >/dev/null 2>&1; then
    yum -y install iptables iptables-services >/dev/null
  elif command -v dnf >/dev/null 2>&1; then
    dnf -y install iptables iptables-services >/dev/null
  else
    echo "FAIL: Neither yum nor dnf available to install packages (${CONTROL_ID})"
    exit 1
  fi
}

unit_exists() {
  systemctl list-unit-files "${UNIT}" >/dev/null 2>&1
}

unmask_enable_start() {
  # Unmask if masked
  if systemctl is-enabled "${UNIT}" 2>/dev/null | grep -q '^masked$'; then
    systemctl unmask "${UNIT}" >/dev/null
  fi
  # Enable and start now
  systemctl daemon-reload >/dev/null
  systemctl --now enable "${UNIT}" >/dev/null
  # Defensive: restart to ensure running
  systemctl restart "${UNIT}" >/dev/null || true
}

verify_state() {
  local ok=1
  unit_exists || ok=0
  [[ "$(systemctl is-enabled "${UNIT}" 2>/dev/null || true)" == "enabled" ]] || ok=0
  [[ "$(systemctl is-active  "${UNIT}" 2>/dev/null || true)" == "active"  ]] || ok=0
  # Sanity: iptables should respond
  iptables -L >/dev/null 2>&1 || ok=0
  return $ok
}

main() {
  require_root
  ensure_installed

  if ! unit_exists; then
    echo "FAIL: ${UNIT} not found (verify iptables-services installation) (${CONTROL_ID})"
    exit 1
  fi

  unmask_enable_start

  if verify_state; then
    echo "OK: iptables service is enabled and running (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: iptables service is not enabled and running (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
