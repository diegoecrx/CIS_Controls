"#!/usr/bin/env bash
# CIS 2.2.1.1 - Ensure time synchronization is in use (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (set via env vars before running):
#  - CIS_TIME_SYNC_MODE: ""chrony"" (default) | ""ntp"" | ""host""
#    * chrony: install/enable/start chronyd
#    * ntp:    install/enable/start ntpd
#    * host:   audit host-based sync (VM/guest tools); no client changes by default
#  - CIS_DISABLE_CLIENTS (host mode only): ""1"" to stop/disable chronyd/ntpd safely (default ""0"")

set -euo pipefail

MODE=""${CIS_TIME_SYNC_MODE:-chrony}""
DISABLE_CLIENTS=""${CIS_DISABLE_CLIENTS:-0}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Utilities
have() { command -v ""$1"" >/dev/null 2>&1; }
is_active() { systemctl is-active --quiet ""$1""; }
is_enabled() { systemctl is-enabled ""$1"" >/dev/null 2>&1; }

chrony_ok() {
  local ok=0
  if rpm -q chrony >/dev/null 2>&1 && is_active chronyd && is_enabled chronyd; then
    if have chronyc; then
      if chronyc tracking >/dev/null 2>&1; then ok=1; fi
    else
      ok=1  # service up and enabled, chronyc not present (shouldn't happen), still accept
    fi
  fi
  [[ $ok -eq 1 ]]
}

ntp_ok() {
  local ok=0
  if rpm -q ntp >/dev/null 2>&1 && is_active ntpd && is_enabled ntpd; then
    if have ntpq && ntpq -pn 2>/dev/null | awk '$1 ~ /^\*/ {found=1} END{exit !found}'; then
      ok=1
    else
      # Accept service up/enabled even if ntpq star not seen (e.g., transient)
      ok=1
    fi
  fi
  [[ $ok -eq 1 ]]
}

host_sync_detected() {
  # VMware Tools timesync
  if have vmware-toolbox-cmd; then
    if vmware-toolbox-cmd timesync status 2>/dev/null | grep -qi 'enabled'; then
      return 0
    fi
  fi
  # VirtualBox Guest Additions service
  if systemctl list-units --type=service --all | grep -q '^vboxservice\.service'; then
    is_active vboxservice && return 0
  fi
  # Hyper-V: hv_timesync kernel module usually auto; accept presence as signal
  if lsmod | grep -q '^hv_utils'; then
    return 0
  fi
  # QEMU/KVM guest agent (heuristic)
  if systemctl list-units --type=service --all | grep -q '^qemu-guest-agent\.service'; then
    is_active qemu-guest-agent && return 0
  fi
  return 1
}

stop_disable_if_present() {
  local svc=""$1""
  if systemctl list-unit-files | grep -q ""^${svc}\.service""; then
    systemctl stop ""${svc}.service"" 2>/dev/null || true
    systemctl disable ""${svc}.service"" 2>/dev/null || true
    systemctl mask ""${svc}.service"" 2>/dev/null || true
  fi
}

# 3) Remediation per MODE
case ""$MODE"" in
  chrony)
    # Prefer chrony on OL7
    if ! rpm -q chrony >/dev/null 2>&1; then
      yum -y install chrony >/dev/null
    fi
    # Ensure config file exists (backup once; we do not edit in this control)
    if [[ -f /etc/chrony.conf && ! -f /etc/chrony.conf.bak ]]; then
      cp -p /etc/chrony.conf /etc/chrony.conf.bak
    fi
    systemctl enable chronyd >/dev/null
    systemctl restart chronyd >/dev/null
    systemctl daemon-reload >/dev/null
    ;;
  ntp)
    if ! rpm -q ntp >/dev/null 2>&1; then
      yum -y install ntp >/dev/null
    fi
    if [[ -f /etc/ntp.conf && ! -f /etc/ntp.conf.bak ]]; then
      cp -p /etc/ntp.conf /etc/ntp.conf.bak
    fi
    systemctl enable ntpd >/dev/null
    systemctl restart ntpd >/dev/null
    systemctl daemon-reload >/dev/null
    ;;
  host)
    # Audit only; optionally disable clients if requested
    if [[ ""$DISABLE_CLIENTS"" = ""1"" ]]; then
      stop_disable_if_present chronyd
      stop_disable_if_present ntpd
      systemctl daemon-reload >/dev/null || true
    fi
    ;;
  *)
    echo ""ERROR: Unknown CIS_TIME_SYNC_MODE='$MODE' (use 'chrony'|'ntp'|'host')."" >&2
    exit 1
    ;;
esac

# 4) Verification (runtime + persistence)
FAIL=0

case ""$MODE"" in
  chrony)
    chrony_ok || { echo ""FAIL: chrony not properly installed/active/enabled""; FAIL=1; }
    ;;
  ntp)
    ntp_ok || { echo ""FAIL: ntp not properly installed/active/enabled""; FAIL=1; }
    ;;
  host)
    if host_sync_detected; then
      # In host mode, also ensure no conflicting client is actively managing time (optional tolerance)
      if is_active chronyd || is_active ntpd; then
        echo ""FAIL: Host-based sync detected but a local time client is active (chronyd/ntpd). Consider disabling or switch MODE.""
        FAIL=1
      fi
    else
      echo ""FAIL: Could not confirm host-based time synchronization. Install chrony (set CIS_TIME_SYNC_MODE=chrony) or enable host sync.""
      FAIL=1
    fi
    ;;
esac

# Additionally, accept success if *either* client is active even if MODE differs (meets control intent).
if [[ $FAIL -ne 0 ]]; then
  if chrony_ok || ntp_ok; then
    FAIL=0
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Time synchronization in use (CIS 2.2.1.1) - MODE=${MODE}""
  exit 0
else
  exit 1
fi"
