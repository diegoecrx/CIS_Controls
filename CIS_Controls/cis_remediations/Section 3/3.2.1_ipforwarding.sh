#!/usr/bin/env bash
# 3.2.1 Ensure IP forwarding is disabled (CIS Oracle Linux 7)
# Defaults to most secure: disable IPv4 and IPv6 forwarding (runtime + persistence).
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.2.1"
SYSCTL_DROPIN="/etc/sysctl.d/99-cis-ip-forwarding.conf"

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

# Comment any lines that explicitly enable forwarding (=1) in system sysctl files
sanitize_conflicting_sysctl() {
  local paths=(
    "/etc/sysctl.conf"
    "/etc/sysctl.d/*.conf"
    "/usr/lib/sysctl.d/*.conf"
    "/run/sysctl.d/*.conf"
  )
  local file
  shopt -s nullglob
  for pattern in "${paths[@]}"; do
    for file in $pattern; do
      # Skip our own drop-in; we will manage it separately
      [[ "$file" == "$SYSCTL_DROPIN" ]] && continue
      # Only touch if there is a conflicting enable (=1)
      if grep -Eq '^\s*net\.ipv4\.ip_forward\s*=\s*1\b' "$file" 2>/dev/null || \
         grep -Eq '^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1\b' "$file" 2>/dev/null; then
        backup_file "$file"
        sed -ri \
          -e 's/^\s*(net\.ipv4\.ip_forward\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv6\.conf\.all\.forwarding\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          "$file"
      fi
    done
  done
  shopt -u nullglob
}

write_persistent_dropin() {
  ensure_dir "/etc/sysctl.d"
  backup_file "$SYSCTL_DROPIN"
  cat > "$SYSCTL_DROPIN" <<'EOF'
# Managed by CIS control 3.2.1 - Disable IP forwarding
# IPv4
net.ipv4.ip_forward = 0
# IPv6
net.ipv6.conf.all.forwarding = 0
EOF
  chmod 0644 "$SYSCTL_DROPIN"
}

apply_runtime() {
  # Runtime enforcement
  sysctl -w net.ipv4.ip_forward=0 >/dev/null
  sysctl -w net.ipv4.route.flush=1 >/dev/null
  sysctl -w net.ipv6.conf.all.forwarding=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv6.route.flush=1 >/dev/null 2>&1 || true
  # Reload all to ensure persistence applied
  sysctl --system >/dev/null
}

verify_runtime() {
  local v4 v6 ok=0
  v4="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 1)"
  v6="$(sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null || echo 1)"
  if [[ "$v4" == "0" && "$v6" == "0" ]]; then ok=1; fi
  return $(( ok == 1 ? 0 : 1 ))
}

verify_persistence() {
  local ok=1
  # Drop-in must exist and contain exact settings
  if [[ ! -f "$SYSCTL_DROPIN" ]]; then ok=0; fi
  grep -Eq '^\s*net\.ipv4\.ip_forward\s*=\s*0\b' "$SYSCTL_DROPIN" || ok=0
  grep -Eq '^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*0\b' "$SYSCTL_DROPIN" || ok=0

  # Ensure no later/overriding files set them to 1 (including /etc/sysctl.conf which loads last)
  local offenders
  offenders="$(grep -Els '^\s*(net\.ipv4\.ip_forward|net\.ipv6\.conf\.all\.forwarding)\s*=\s*1\b' \
    /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null || true)"
  if [[ -n "$offenders" ]]; then
    ok=0
  fi
  return $ok
}

main() {
  require_root
  sanitize_conflicting_sysctl
  write_persistent_dropin
  apply_runtime

  FAIL=0
  verify_runtime   || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: IP forwarding disabled (runtime + persistence) (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: IP forwarding not fully disabled (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"