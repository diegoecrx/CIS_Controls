"#!/usr/bin/env bash
# 3.5.1.5 Ensure firewalld default zone is set (CIS Oracle Linux 7)
# Default zone: ""public"". Override via env var: FIREWALLD_DEFAULT_ZONE=<zone>
# Actions:
#   - Verify firewalld installed and running
#   - Ensure requested zone exists
#   - Set runtime & permanent default zone, then reload
# Verification:
#   - firewall-cmd --get-default-zone == <zone>
#   - /etc/firewalld/firewalld.conf DefaultZone=<zone>
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.5""
ZONE=""${FIREWALLD_DEFAULT_ZONE:-public}""
CONF=""/etc/firewalld/firewalld.conf""

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

firewalld_installed() { rpm -q firewalld >/dev/null 2>&1; }
firewalld_running() { systemctl is-active firewalld >/dev/null 2>&1; }

ensure_running() {
  if ! firewalld_running; then
    # Start without enabling; prior controls should have enabled it
    systemctl start firewalld >/dev/null 2>&1 || {
      echo ""FAIL: firewalld is not running and could not be started (${CONTROL_ID})""
      exit 1
    }
  fi
}

zone_exists() {
  firewall-cmd --get-zones 2>/dev/null | tr ' ' '\n' | grep -qx ""$ZONE""
}

set_default_zone() {
  # Runtime
  firewall-cmd --set-default-zone=""$ZONE"" >/dev/null
  # Permanent
  firewall-cmd --permanent --set-default-zone=""$ZONE"" >/dev/null
  # Apply permanent to runtime
  firewall-cmd --reload >/dev/null
}

verify_runtime() {
  local cur
  cur=""$(firewall-cmd --get-default-zone 2>/dev/null || echo """")""
  [[ ""$cur"" == ""$ZONE"" ]]
}

verify_persistence() {
  # Prefer reading config file; fallback to grep if structure changes
  [[ -f ""$CONF"" ]] || return 1
  grep -Eq ""^DefaultZone=${ZONE}\b"" ""$CONF""
}

main() {
  require_root

  if ! firewalld_installed; then
    echo ""FAIL: firewalld package not installed (run CIS 3.5.1.1 first) (${CONTROL_ID})""
    exit 1
  fi

  ensure_running

  if ! zone_exists; then
    echo ""FAIL: Zone '$ZONE' does not exist. Available: $(firewall-cmd --get-zones 2>/dev/null) (${CONTROL_ID})""
    exit 1
  fi

  set_default_zone

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: firewalld default zone set to '${ZONE}' (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: firewalld default zone not correctly set to '${ZONE}' (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
	