"#!/usr/bin/env bash
# 3.5.1.6 Ensure network interfaces are assigned to appropriate zone (CIS Oracle Linux 7)
# Manual control with audit + optional remediation.
#
# Usage (remediation):
#   IFACE_ZONE_MAP=""eth0:public,eth1:internal"" ./3.5.1.6_firewalld_interface_zones.sh
#
# Behavior:
#   - If IFACE_ZONE_MAP is not set, prints an audit report of runtime and persistent mappings and exits 1.
#   - If IFACE_ZONE_MAP is set, assigns each interface to the specified zone both at runtime and permanently,
#     then verifies mappings.
#
# Notes:
#   - Persistent assignment uses: firewall-cmd --permanent --zone=<Z> --add-interface=<IF>
#   - Runtime assignment uses:    firewall-cmd --zone=<Z> --change-interface=<IF>
#   - The script also removes persistent assignments for the interface from other zones to avoid ambiguity.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.6""
MAP=""${IFACE_ZONE_MAP:-}""

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
    systemctl start firewalld >/dev/null 2>&1 || {
      echo ""FAIL: firewalld is not running and could not be started (${CONTROL_ID})""
      exit 1
    }
  fi
}

zones_list() {
  firewall-cmd --get-zones 2>/dev/null | tr ' ' '\n' | sort -u
}

zone_exists() {
  local z=""$1""
  zones_list | grep -qx ""${z}""
}

audit_report() {
  echo ""AUDIT: firewalld zone/interface mappings (${CONTROL_ID})""
  echo ""- Runtime active zones:""
  firewall-cmd --get-active-zones 2>/dev/null || echo ""(none)""
  echo ""- Runtime zone per interface:""
  for n in /sys/class/net/*; do
    [[ -e ""$n"" ]] || continue
    local ifc; ifc=""$(basename ""$n"")""
    printf ""  %s -> %s\n"" ""$ifc"" ""$(firewall-cmd --get-zone-of-interface=""$ifc"" 2>/dev/null || echo unknown)""
  done
  echo ""- Persistent assignments by zone:""
  for z in $(zones_list); do
    echo ""  ${z}: $(firewall-cmd --permanent --zone=""$z"" --list-interfaces 2>/dev/null || true)""
  done
}

assign_interface() {
  local ifc=""$1"" zone=""$2""

  # Validate zone
  if ! zone_exists ""$zone""; then
    echo ""FAIL: Zone '${zone}' does not exist. Available: $(zones_list | tr '\n' ' ')"" ; return 1
  fi

  # Runtime assignment (interface should generally exist for runtime change)
  firewall-cmd --zone=""$zone"" --change-interface=""$ifc"" >/dev/null 2>&1 || true

  # Persistent assignment: add to desired zone
  firewall-cmd --permanent --zone=""$zone"" --add-interface=""$ifc"" >/dev/null

  # Remove persistent assignment from all other zones
  for z in $(zones_list); do
    [[ ""$z"" == ""$zone"" ]] && continue
    # Remove only if present
    if firewall-cmd --permanent --zone=""$z"" --list-interfaces 2>/dev/null | grep -qw ""$ifc""; then
      firewall-cmd --permanent --zone=""$z"" --remove-interface=""$ifc"" >/dev/null || true
    fi
  done
}

verify_mapping() {
  local ifc=""$1"" zone=""$2""
  local ok=1

  # Verify persistent: interface listed only in desired zone
  if ! firewall-cmd --permanent --zone=""$zone"" --list-interfaces 2>/dev/null | grep -qw ""$ifc""; then
    ok=0
  fi
  # Ensure no other zone lists it persistently
  for z in $(zones_list); do
    [[ ""$z"" == ""$zone"" ]] && continue
    if firewall-cmd --permanent --zone=""$z"" --list-interfaces 2>/dev/null | grep -qw ""$ifc""; then
      ok=0
    fi
  done

  # Verify runtime (interface must exist for a strict check)
  if [[ -e ""/sys/class/net/$ifc"" ]]; then
    local rzone
    rzone=""$(firewall-cmd --get-zone-of-interface=""$ifc"" 2>/dev/null || echo unknown)""
    [[ ""$rzone"" == ""$zone"" ]] || ok=0
  fi

  return $ok
}

apply_and_verify() {
  local fail=0
  # Normalize commas and whitespace
  local pair
  IFS=',' read -r -a pairs <<< ""$MAP""
  # Reload once at the end (for persistent changes)
  for pair in ""${pairs[@]}""; do
    pair=""$(echo ""$pair"" | xargs)""
    [[ -z ""$pair"" ]] && continue
    local ifc=""${pair%%:*}""
    local zone=""${pair#*:}""
    if [[ -z ""$ifc"" || -z ""$zone"" || ""$ifc"" == ""$zone"" ]]; then
      echo ""FAIL: Invalid mapping entry '$pair' (expected IFACE:ZONE)""; fail=1; continue
    fi

    assign_interface ""$ifc"" ""$zone"" || fail=1
  done

  # Apply persistent changes to runtime
  firewall-cmd --reload >/dev/null

  # Verify all
  for pair in ""${pairs[@]}""; do
    pair=""$(echo ""$pair"" | xargs)""
    [[ -z ""$pair"" ]] && continue
    local ifc=""${pair%%:*}""
    local zone=""${pair#*:}""

    verify_mapping ""$ifc"" ""$zone"" || { echo ""FAIL: Verification failed for ${ifc} -> ${zone}""; fail=1; }
  done

  if [[ $fail -eq 0 ]]; then
    echo ""OK: Interfaces assigned to specified zones (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: One or more interface-to-zone assignments failed (${CONTROL_ID})""
    exit 1
  fi
}

main() {
  require_root

  if ! firewalld_installed; then
    echo ""FAIL: firewalld not installed (run CIS 3.5.1.1 first) (${CONTROL_ID})""
    exit 1
  fi
  ensure_running

  if [[ -z ""$MAP"" ]]; then
    audit_report
    echo ""NOTE: Provide IFACE_ZONE_MAP=\""eth0:public,eth1:internal\"" to remediate (${CONTROL_ID})""
    exit 1
  fi

  apply_and_verify
}

main ""$@"""
