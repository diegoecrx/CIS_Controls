"#!/usr/bin/env bash
# 3.5.1.7 Ensure firewalld drops unnecessary services and ports (CIS Oracle Linux 7)
#
# Manual control with Audit + Optional Remediation.
#
# Usage (examples):
#   # Remove ssh and cockpit services, and 25/tcp from all zones:
#   FW_DROP_SERVICES=""ssh,cockpit"" FW_DROP_PORTS=""25/tcp"" ./3.5.1.7_firewalld_drop_unnecessary.sh
#
#   # Scope to zones only:
#   FW_ZONES=""public,internal"" FW_DROP_SERVICES=""cockpit"" ./3.5.1.7_firewalld_drop_unnecessary.sh
#
# Behavior:
#   - If FW_DROP_SERVICES and FW_DROP_PORTS are both empty, prints an audit report and exits 1.
#   - Otherwise removes listed items from the selected zones (runtime + permanent), reloads, and verifies.
#
# Notes:
#   - Creates timestamped backups of target zone XML files in /etc/firewalld/zones/ before permanent changes.
#   - Idempotent; safe to rerun.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.1.7""

FW_ZONES=""${FW_ZONES:-}""                 # comma-separated zones; if empty, all zones
FW_DROP_SERVICES=""${FW_DROP_SERVICES:-}"" # comma-separated service names (e.g., ""cockpit,ssh"")
FW_DROP_PORTS=""${FW_DROP_PORTS:-}""       # comma-separated ports ""num/proto"" (e.g., ""25/tcp,123/udp"")

timestamp() { date +""%Y%m%d-%H%M%S""; }

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

selected_zones() {
  if [[ -n ""$FW_ZONES"" ]]; then
    echo ""$FW_ZONES"" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u
  else
    zones_list
  fi
}

audit_report() {
  echo ""AUDIT: firewalld services and ports per zone (${CONTROL_ID})""
  echo ""- Default zone: $(firewall-cmd --get-default-zone 2>/dev/null || echo unknown)""
  echo ""- Active zones and interfaces:""
  firewall-cmd --get-active-zones 2>/dev/null || echo ""(none)""
  echo ""- Persistent configuration:""
  for z in $(zones_list); do
    echo ""  Zone: ${z}""
    echo ""    Services: $(firewall-cmd --permanent --zone=""$z"" --list-services 2>/dev/null || true)""
    echo ""    Ports:    $(firewall-cmd --permanent --zone=""$z"" --list-ports 2>/dev/null || true)""
  done
}

backup_zone_files() {
  local z dir=""/etc/firewalld/zones"" ts; ts=""$(timestamp)""
  [[ -d ""$dir"" ]] || return 0
  for z in ""$@""; do
    # zone files may be named <zone>.xml
    if [[ -f ""${dir}/${z}.xml"" ]]; then
      cp -a --preserve=all ""${dir}/${z}.xml"" ""${dir}/${z}.xml.bak.${ts}""
    fi
  done
}

# Normalize comma-separated lists into lines
normalize_list() {
  echo ""$1"" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' || true
}

remove_items_for_zone() {
  local z=""$1""; shift
  local services=""$1""; shift
  local ports=""$1""

  # Runtime removals (best-effort; may not be present)
  while read -r svc; do
    [[ -z ""$svc"" ]] && continue
    firewall-cmd --zone=""$z"" --remove-service=""$svc"" >/dev/null 2>&1 || true
  done < <(normalize_list ""$services"")

  while read -r prt; do
    [[ -z ""$prt"" ]] && continue
    firewall-cmd --zone=""$z"" --remove-port=""$prt"" >/dev/null 2>&1 || true
  done < <(normalize_list ""$ports"")

  # Permanent removals (authoritative)
  while read -r svc; do
    [[ -z ""$svc"" ]] && continue
    firewall-cmd --permanent --zone=""$z"" --remove-service=""$svc"" >/dev/null 2>&1 || true
  done < <(normalize_list ""$services"")

  while read -r prt; do
    [[ -z ""$prt"" ]] && continue
    firewall-cmd --permanent --zone=""$z"" --remove-port=""$prt"" >/dev/null 2>&1 || true
  done < <(normalize_list ""$ports"")
}

verify_removed() {
  local ok=1 z svc prt
  for z in ""$@""; do
    # Check persistent (authoritative)
    for svc in $(normalize_list ""$FW_DROP_SERVICES""); do
      [[ -z ""$svc"" ]] && continue
      firewall-cmd --permanent --zone=""$z"" --list-services 2>/dev/null | grep -qw ""$svc"" && ok=0
    done
    for prt in $(normalize_list ""$FW_DROP_PORTS""); do
      [[ -z ""$prt"" ]] && continue
      firewall-cmd --permanent --zone=""$z"" --list-ports 2>/dev/null | tr ' ' '\n' | grep -qx ""$prt"" && ok=0
    done

    # Check runtime state mirrors (non-blocking if interface-less zone)
    for svc in $(normalize_list ""$FW_DROP_SERVICES""); do
      [[ -z ""$svc"" ]] && continue
      firewall-cmd --zone=""$z"" --list-services 2>/dev/null | grep -qw ""$svc"" && ok=0
    done
    for prt in $(normalize_list ""$FW_DROP_PORTS""); do
      [[ -z ""$prt"" ]] && continue
      firewall-cmd --zone=""$z"" --list-ports 2>/dev/null | tr ' ' '\n' | grep -qx ""$prt"" && ok=0
    done
  done
  return $ok
}

main() {
  require_root

  if ! firewalld_installed; then
    echo ""FAIL: firewalld not installed (run CIS 3.5.1.1 first) (${CONTROL_ID})""
    exit 1
  fi
  ensure_running

  local zones; zones=($(selected_zones))

  if [[ -z ""$FW_DROP_SERVICES"" && -z ""$FW_DROP_PORTS"" ]]; then
    audit_report
    echo ""NOTE: Provide FW_DROP_SERVICES and/or FW_DROP_PORTS (and optional FW_ZONES) to remediate (${CONTROL_ID})""
    exit 1
  fi

  # Backup targeted zone XMLs before permanent changes
  backup_zone_files ""${zones[@]}""

  # Apply removals per zone
  for z in ""${zones[@]}""; do
    remove_items_for_zone ""$z"" ""$FW_DROP_SERVICES"" ""$FW_DROP_PORTS""
  done

  # Make runtime reflect permanent
  firewall-cmd --runtime-to-permanent >/dev/null || true
  firewall-cmd --reload >/dev/null

  if verify_removed ""${zones[@]}""; then
    echo ""OK: Unnecessary services/ports removed from zones: ${zones[*]} (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: Some services/ports remain present in one or more zones (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
