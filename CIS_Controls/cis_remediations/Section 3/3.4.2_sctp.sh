"#!/usr/bin/env bash
# 3.4.2 Ensure SCTP is disabled (CIS Oracle Linux 7)
# Persists: /etc/modprobe.d/sctp.conf with ""install sctp /bin/true"" (and blacklist)
# Runtime: unload if currently loaded
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.4.2""
DROPIN=""/etc/modprobe.d/sctp.conf""

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

backup_file() {
  local f=""$1""
  if [[ -f ""$f"" ]]; then
    cp -a --preserve=all ""$f"" ""${f}.bak.$(timestamp)""
  fi
}

ensure_dir() {
  local d=""$1"" m=""${2:-0755}""
  install -d -m ""$m"" ""$d""
}

persist_disable_sctp() {
  ensure_dir ""/etc/modprobe.d""
  backup_file ""$DROPIN""
  cat > ""$DROPIN"" <<'EOF'
# Managed by CIS control 3.4.2 - Disable SCTP
# Prevent autoload of sctp
install sctp /bin/true
# Defensive: also blacklist
blacklist sctp
EOF
  chmod 0644 ""$DROPIN""
}

runtime_unload_sctp() {
  if lsmod | grep -qw '^sctp'; then
    modprobe -r sctp 2>/dev/null || rmmod sctp 2>/dev/null || true
  fi
}

verify_runtime() {
  # SCTP module must not be loaded
  if lsmod | grep -qw '^sctp'; then
    return 1
  fi
  return 0
}

verify_persistence() {
  local ok=1
  [[ -f ""$DROPIN"" ]] || ok=0
  grep -qx 'install sctp /bin/true' ""$DROPIN"" || ok=0
  # modprobe simulation should show /bin/true (or module not found)
  if ! modprobe -n -v sctp 2>/dev/null | grep -qE '^(install|override).*/bin/true|^insmod .*sctp.*not found|^modprobe: FATAL: Module sctp not found'; then
    ok=0
  fi
  return $ok
}

main() {
  require_root
  persist_disable_sctp
  runtime_unload_sctp

  FAIL=0
  verify_runtime || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: SCTP disabled (runtime unloaded, persistence ensured) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: SCTP not fully disabled (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
