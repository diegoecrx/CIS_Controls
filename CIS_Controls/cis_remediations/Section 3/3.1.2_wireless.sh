#!/usr/bin/env bash
# 3.1.2 Ensure wireless interfaces are disabled (CIS Oracle Linux 7)
# Strategy:
#  - Runtime: turn radios off (nmcli/rfkill), down wireless links, stop wpa_supplicant if present
#  - Persistence: block wireless driver modules via modprobe "install ... /bin/true", mask wpa_supplicant
# Notes:
#  - Idempotent; safe to rerun
#  - Backups created for edited files
#  - Exits 0 on full success, 1 otherwise
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.1.2"
DROPIN="/etc/modprobe.d/disable_wireless.conf"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

timestamp() { date +"%Y%m%d-%H%M%S"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "FAIL: Must run as root (${CONTROL_ID})"
    exit 1
  fi
}

backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a --preserve=all "$f" "${f}.bak.$(timestamp)"
  fi
}

ensure_dir() {
  local d="$1" m="${2:-0755}"
  install -d -m "$m" "$d"
}

# Detect wireless interfaces: any netdev with /wireless dir present
list_wireless_ifaces() {
  for d in /sys/class/net/*; do
    [[ -d "$d/wireless" ]] && basename "$d"
  done | sort -u
}

# Map ifaces to kernel module names that drive them
list_wireless_modules() {
  local iface modpath
  for iface in $(list_wireless_ifaces); do
    modpath="$(readlink -f "/sys/class/net/${iface}/device/driver/module" 2>/dev/null || true)"
    [[ -n "$modpath" ]] && basename "$modpath"
  done | sort -u
}

turn_off_radios() {
  if command -v nmcli >/dev/null 2>&1; then
    nmcli radio all off || true
  fi
  # rfkill is a secondary method; persist usually handled by systemd-rfkill
  if command -v rfkill >/dev/null 2>&1; then
    rfkill block all || true
  fi
}

down_wireless_links() {
  local iface
  for iface in $(list_wireless_ifaces); do
    ip link set dev "$iface" down >/dev/null 2>&1 || true
  done
}

stop_mask_wpa() {
  if systemctl list-unit-files | grep -q '^wpa_supplicant\.service'; then
    systemctl stop wpa_supplicant.service >/dev/null 2>&1 || true
    systemctl disable wpa_supplicant.service >/dev/null 2>&1 || true
    systemctl mask wpa_supplicant.service >/dev/null 2>&1 || true
  fi
}

persist_block_modules() {
  local mods mod
  mods="$(list_wireless_modules || true)"
  ensure_dir "/etc/modprobe.d"
  backup_file "$DROPIN"
  # Start with any existing (to preserve unrelated content), then ensure required lines exist
  touch "$DROPIN"
  chmod 0644 "$DROPIN"

  if [[ -n "$mods" ]]; then
    # Build a temp with desired lines
    : > "$TMPDIR/desired"
    for mod in $mods; do
      echo "install ${mod} /bin/true" >> "$TMPDIR/desired"
      echo "blacklist ${mod}" >> "$TMPDIR/desired"
    done
    # Merge: append any missing lines
    while IFS= read -r line; do
      grep -qxF "$line" "$DROPIN" || echo "$line" >> "$DROPIN"
    done < "$TMPDIR/desired"
  fi
}

apply_changes() {
  # No daemon-reload required for modprobe drop-ins; ensure permissions
  chmod 0644 "$DROPIN" || true
}

verify_runtime() {
  local ok=1
  # Radios via nmcli (if available)
  if command -v nmcli >/dev/null 2>&1; then
    # nmcli radio all should output "disabled" states for wifi/wwan
    if nmcli -t -f WIFI,WWAN radio | grep -qE '(^|:)enabled'; then
      ok=0
    fi
  fi
  # Ensure each wireless iface is DOWN
  local iface state
  for iface in $(list_wireless_ifaces); do
    state="$(cat "/sys/class/net/${iface}/operstate" 2>/dev/null || echo "unknown")"
    [[ "$state" == "down" || "$state" == "unknown" ]] || ok=0
  done
  return $ok
}

verify_persist() {
  local ok=1
  # Check modprobe drop-in contains rules for detected modules
  local mods mod
  mods="$(list_wireless_modules || true)"
  if [[ -n "$mods" ]]; then
    for mod in $mods; do
      grep -qx "install ${mod} /bin/true" "$DROPIN" || ok=0
      grep -qx "blacklist ${mod}" "$DROPIN" || ok=0
    done
  fi
  # wpa_supplicant masked if present
  if systemctl list-unit-files | grep -q '^wpa_supplicant\.service'; then
    systemctl is-enabled wpa_supplicant.service >/dev/null 2>&1 && ok=0
    systemctl is-enabled wpa_supplicant.service >/dev/null 2>&1 || true
    systemctl is-enabled wpa_supplicant.service >/dev/null 2>&1 | grep -q masked || ok=0
  fi
  return $ok
}

main() {
  require_root

  turn_off_radios
  down_wireless_links
  stop_mask_wpa
  persist_block_modules
  apply_changes

  FAIL=0
  verify_runtime || FAIL=1
  verify_persist || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: Wireless interfaces disabled (runtime + persistence) (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: Wireless disable not fully enforced (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"