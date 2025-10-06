#!/usr/bin/env bash
# 3.1.1 Disable IPv6 (CIS Oracle Linux 7)
# Method default: sysctl. To use GRUB, export IPV6_DISABLE_METHOD=grub
# APPLICABILITY FLAGS (do not enforce; informational only)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.1.1"
METHOD="${IPV6_DISABLE_METHOD:-sysctl}"  # acceptable: sysctl | grub
SYSCTL_DROPIN="/etc/sysctl.d/99-cis-ipv6.conf"
GRUB_DEFAULT="/etc/default/grub"
GRUB_CFG_BIOS="/boot/grub2/grub.cfg"
GRUB_CFG_EFI="/boot/efi/EFI/redhat/grub.cfg"

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
  local d="$1"
  install -d -m 0755 "$d"
}

apply_sysctl_method() {
  # Persist settings
  ensure_dir "/etc/sysctl.d"
  backup_file "$SYSCTL_DROPIN"
  cat > "$SYSCTL_DROPIN" <<'EOF'
# Managed by CIS control 3.1.1 - Disable IPv6
# Set disable_ipv6 for all and default to 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
  chmod 0644 "$SYSCTL_DROPIN"

  # Apply immediately (runtime)
  sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null
  sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null
  # Be thorough: attempt per-interface where present
  for p in /proc/sys/net/ipv6/conf/*/disable_ipv6; do
    [[ -e "$p" ]] || continue
    sysctl -w "net.ipv6.conf.${p%/*/*/*/*/*/*/*/*/}.disable_ipv6=1" >/dev/null 2>&1 || true
  done
  # Flush routes as per CIS
  sysctl -w net.ipv6.route.flush=1 >/dev/null

  # Load all sysctl settings
  sysctl --system >/dev/null
}

apply_grub_method() {
  # Add ipv6.disable=1 to GRUB_CMDLINE_LINUX and rebuild grub.cfg
  if [[ ! -f "$GRUB_DEFAULT" ]]; then
    echo "FAIL: $GRUB_DEFAULT not found (${CONTROL_ID})"
    exit 1
  fi
  backup_file "$GRUB_DEFAULT"

  # Ensure GRUB_CMDLINE_LINUX exists
  if ! grep -q '^GRUB_CMDLINE_LINUX=' "$GRUB_DEFAULT"; then
    echo 'GRUB_CMDLINE_LINUX=""' >> "$GRUB_DEFAULT"
  fi

  # Insert kernel arg if missing (preserve other args)
  if grep -q '^[[:space:]]*GRUB_CMDLINE_LINUX=.*ipv6.disable=1' "$GRUB_DEFAULT"; then
    : # already present
  else
    # Append within the quoted value
    sed -r -i 's|^(GRUB_CMDLINE_LINUX="[^"]*)(".*)$|\1 ipv6.disable=1\2|' "$GRUB_DEFAULT"
  fi

  # Rebuild grub configuration (BIOS and/or UEFI)
  if [[ -d /sys/firmware/efi ]]; then
    grub2-mkconfig -o "$GRUB_CFG_EFI" >/dev/null
  fi
  grub2-mkconfig -o "$GRUB_CFG_BIOS" >/dev/null
}

verify_runtime_sysctl() {
  local a d
  a="$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)"
  d="$(sysctl -n net.ipv6.conf.default.disable_ipv6 2>/dev/null || echo 0)"
  if [[ "$a" == "1" && "$d" == "1" ]]; then
    return 0
  fi
  return 1
}

verify_persist_sysctl() {
  if [[ -f "$SYSCTL_DROPIN" ]] && \
     grep -q '^net\.ipv6\.conf\.all\.disable_ipv6[[:space:]]*=[[:space:]]*1' "$SYSCTL_DROPIN" && \
     grep -q '^net\.ipv6\.conf\.default\.disable_ipv6[[:space:]]*=[[:space:]]*1' "$SYSCTL_DROPIN"; then
    return 0
  fi
  return 1
}

verify_runtime_grub() {
  # kernel cmdline active for current boot?
  if grep -qw 'ipv6.disable=1' /proc/cmdline; then
    return 0
  fi
  return 1
}

verify_persist_grub() {
  local ok_default=1 ok_cfg=1
  grep -q '^[[:space:]]*GRUB_CMDLINE_LINUX=.*ipv6.disable=1' "$GRUB_DEFAULT" || ok_default=0
  if [[ -f "$GRUB_CFG_BIOS" ]] && grep -qw 'ipv6.disable=1' "$GRUB_CFG_BIOS"; then :; else ok_cfg=0; fi
  # On UEFI, also accept EFI grub.cfg
  if [[ -d /sys/firmware/efi ]]; then
    if [[ -f "$GRUB_CFG_EFI" ]] && grep -qw 'ipv6.disable=1' "$GRUB_CFG_EFI"; then
      ok_cfg=1
    fi
  fi
  [[ $ok_default -eq 1 && $ok_cfg -eq 1 ]]
}

main() {
  require_root

  case "$METHOD" in
    sysctl)
      apply_sysctl_method
      ;;
    grub)
      apply_grub_method
      ;;
    *)
      echo "FAIL: Invalid IPV6_DISABLE_METHOD='$METHOD' (use 'sysctl' or 'grub') (${CONTROL_ID})"
      exit 1
      ;;
  esac

  FAIL=0
  if [[ "$METHOD" == "sysctl" ]]; then
    verify_runtime_sysctl || FAIL=1
    verify_persist_sysctl || FAIL=1
  else
    verify_runtime_grub || { 
      # If kernel arg added, a reboot is required for runtime effect; do not fail persistence.
      # Mark runtime as pending but keep persistence check decisive.
      echo "NOTE: Reboot required for GRUB method to take runtime effect (${CONTROL_ID})"
    }
    verify_persist_grub || FAIL=1
  fi

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: IPv6 disabled via ${METHOD} (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: IPv6 disable (${METHOD}) not fully enforced (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"