"#!/usr/bin/env bash
# 1.6.1.6 - Ensure no unconfined services exist (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# 1) Require root (needed to map PIDs -> units reliably)
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure SELinux is enabled at runtime (Enforcing/Permissive)
SESTATUS=""$(getenforce 2>/dev/null || echo ""Unknown"")""
if [[ ""$SESTATUS"" == ""Disabled"" || ""$SESTATUS"" == ""Unknown"" ]]; then
  echo ""FAIL: SELinux runtime is '$SESTATUS'. Enable SELinux (CIS 1.6.1.4/1.6.1.5) before auditing unconfined services.""
  exit 1
fi

# 3) Audit: find processes running in unconfined_service_t
#    Note: user shells commonly run in unconfined_t (ignore those); we only flag unconfined_service_t.
mapfile -t BAD < <(
  ps -eZ -o label,user,pid,comm,cmd --no-headers \
  | awk '$1 ~ /(^|:)unconfined_service_t(:|$)/ {print $0}'
)

if ((${#BAD[@]} == 0)); then
  echo ""OK: No processes running in SELinux type 'unconfined_service_t' (CIS 1.6.1.6).""
  exit 0
fi

echo ""FINDINGS: Processes running under SELinux type 'unconfined_service_t':""
printf '%s\n' ""${BAD[@]}""

# 4) Best-effort mapping to systemd units (helps remediation)
if command -v systemctl >/dev/null 2>&1; then
  echo
  echo ""== Suspected systemd units for the offending PIDs ==""
  while read -r _label _user pid _comm _rest; do
    # Try direct mapping: systemctl status <pid> prints a unit name when known
    UNIT=""$(systemctl status ""$pid"" 2>/dev/null | awk -F'[][]' '/Loaded:.*\.service/ {print $2; exit}')""
    [[ -z ""$UNIT"" ]] && UNIT=""$(systemctl status ""$pid"" 2>/dev/null | awk -F'[][]' '/^● .*\.service/ {print $2; exit}')""
    if [[ -n ""$UNIT"" ]]; then
      printf 'PID %s -> %s\n' ""$pid"" ""$UNIT""
    else
      printf 'PID %s -> (unit not determined)\n' ""$pid""
    fi
  done < <(printf '%s\n' ""${BAD[@]}"")
fi

cat <<'HINT'

Remediation guidance (manual, per service):
  - Identify why the service is unconfined (missing/incorrect SELinux context or policy).
  - Ensure files and directories used by the service have correct labels, e.g.:
      restorecon -FRv /path/to/service/files
  - If the service binary needs a specific type, consider:
      semanage fcontext -a -t <expected_t> ""/path(/.*)?""
      restorecon -RFv /path
  - Review/enable the appropriate SELinux boolean(s) if applicable:
      getsebool -a | grep <service>
      setsebool -P <bool> on
  - As a last resort, develop a minimal custom policy module for the service (audit2allow -M ...).

NOTE: This control fails if ANY unconfined_service_t processes are present.
HINT

exit 1"
