"#!/usr/bin/env bash
# CIS 2.4 - Ensure nonessential services are removed or masked (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Usage / Behavior (configure via env vars or simple files):
#  - CIS_MODE: ""audit"" (default) | ""mask"" | ""remove""
#      audit  = report candidates only
#      mask   = stop + disable + mask candidate services
#      remove = yum remove owning package when determinable (fallback to mask)
#  - CIS_ALLOWLIST: path file with allowed service names (one per line, e.g., sshd.service)
#  - CIS_BLOCKLIST: path file with explicitly nonessential service names (one per line)
#      If both provided: Effective candidates = (Enabled services ∪ BLOCKLIST) − ALLOWLIST.
#      If none provided: candidates = Enabled services − CORE_EXCLUDES (conservative).
#  - CIS_DRYRUN: ""1"" -> show actions but do not change system (default ""0"")
#
# Notes:
#  - This control is site-specific. Provide ALLOWLIST/BLOCKLIST for precise results.
#  - Templated units (name@.service) are handled; we act on instantiated units (name@X.service).
#  - We never touch essential/core units in CORE_EXCLUDES even if listed (safety).

set -euo pipefail

CIS_MODE=""${CIS_MODE:-audit}""
CIS_ALLOWLIST=""${CIS_ALLOWLIST:-}""
CIS_BLOCKLIST=""${CIS_BLOCKLIST:-}""
CIS_DRYRUN=""${CIS_DRYRUN:-0}""

TS=""$(date +%Y%m%d%H%M%S)""
LOG_DIR=""/var/log/cis""
LOG_FILE=""${LOG_DIR}/cis_2_4_${TS}.log""
mkdir -p -m 0750 ""$LOG_DIR""

# 1) Root check
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Helpers
have() { command -v ""$1"" >/dev/null 2>&1; }
log() { echo ""$@"" | tee -a ""$LOG_FILE""; }
unit_fragment_path() { systemctl show -p FragmentPath ""$1"" 2>/dev/null | awk -F= '{print $2}'; }
unit_pkg_owner() {
  local frag; frag=""$(unit_fragment_path ""$1"")""
  [[ -n ""$frag"" && -f ""$frag"" ]] && rpm -qf ""$frag"" 2>/dev/null || true
}

# 3) Define conservative core excludes (never acted upon)
#    Adjust per site policy if needed.
read -r -d '' CORE_EXCLUDES <<'EOF' || true
auditd.service
crond.service
atd.service
rsyslog.service
systemd-journald.service
systemd-logind.service
systemd-udevd.service
ssh.service
sshd.service
dbus.service
network.service
NetworkManager.service
systemd-timesyncd.service
chronyd.service
ntpd.service
getty@.service
rngd.service
irqbalance.service
firewalld.service
iptables.service
ip6tables.service
polkit.service
EOF

# Normalize CORE_EXCLUDES to array
mapfile -t CORE_EXCLUDE_ARR < <(printf ""%s\n"" $CORE_EXCLUDES | sed '/^\s*$/d')

# 4) Load ALLOWLIST/BLOCKLIST (if provided)
ALLOW_SET=()
if [[ -n ""$CIS_ALLOWLIST"" && -f ""$CIS_ALLOWLIST"" ]]; then
  mapfile -t ALLOW_SET < <(sed -E 's/#.*$//;s/^\s+|\s+$//g;/^\s*$/d' ""$CIS_ALLOWLIST"")
fi
BLOCK_SET=()
if [[ -n ""$CIS_BLOCKLIST"" && -f ""$CIS_BLOCKLIST"" ]]; then
  mapfile -t BLOCK_SET < <(sed -E 's/#.*$//;s/^\s+|\s+$//g;/^\s*$/d' ""$CIS_BLOCKLIST"")
fi

# 5) Gather enabled service units (we include sockets too, some services are socket-activated)
mapfile -t ENABLED_SERVICES < <(systemctl list-unit-files --type=service --state=enabled 2>/dev/null | awk 'NF==2 && $2==""enabled""{print $1}')
mapfile -t ENABLED_SOCKETS  < <(systemctl list-unit-files --type=socket  --state=enabled 2>/dev/null | awk 'NF==2 && $2==""enabled""{print $1}')

# 6) Build candidate list
declare -A CANDIDATE=()

# From enabled services
for u in ""${ENABLED_SERVICES[@]}""; do CANDIDATE[""$u""]=1; done
# From enabled sockets (convert socket to its service name when obvious, but also include socket)
for s in ""${ENABLED_SOCKETS[@]}""; do CANDIDATE[""$s""]=1; done
# Explicit blocklist
for b in ""${BLOCK_SET[@]}""; do CANDIDATE[""$b""]=1; done

# Remove core excludes and allowlist entries
for ex in ""${CORE_EXCLUDE_ARR[@]}""; do unset ""CANDIDATE[$ex]"" || true; done
for al in ""${ALLOW_SET[@]}""; do unset ""CANDIDATE[$al]"" || true; done

# Filter out systemd generator/transient junk
for k in ""${!CANDIDATE[@]}""; do
  if [[ ""$k"" =~ \.mount$ || ""$k"" =~ \.swap$ || ""$k"" =~ \.target$ || ""$k"" =~ \.path$ || ""$k"" =~ ^systemd- ]]; then
    unset ""CANDIDATE[$k]""
  fi
done

# If nothing remains and no blocklist given, just audit success
CAND_KEYS=(""${!CANDIDATE[@]}"")

# 7) Action functions
do_mask() {
  local u=""$1""
  systemctl stop ""$u"" 2>/dev/null || true
  systemctl disable ""$u"" 2>/dev/null || true
  systemctl mask ""$u"" 2>/dev/null || true
}

do_remove() {
  local u=""$1""
  local pkg; pkg=""$(unit_pkg_owner ""$u"" || true)""
  if [[ -n ""$pkg"" && ""$pkg"" != ""(none)"" ]]; then
    yum -y remove ""$pkg"" >/dev/null || return 1
    return 0
  fi
  return 2  # no owning package found
}

# 8) Apply mode
FAIL=0
if [[ ""${#CAND_KEYS[@]}"" -eq 0 ]]; then
  log ""OK: No nonessential enabled services/sockets detected (CIS 2.4)""
else
  log ""Candidates (review per policy):""
  for u in ""${CAND_KEYS[@]}""; do log "" - $u""; done

  case ""$CIS_MODE"" in
    audit)
      log ""Audit-only mode. No changes made.""
      ;;
    mask)
      for u in ""${CAND_KEYS[@]}""; do
        if [[ ""$CIS_DRYRUN"" == ""1"" ]]; then
          log ""DRYRUN: would stop/disable/mask $u""
        else
          do_mask ""$u""
          log ""Masked: $u""
        fi
      done
      ;;
    remove)
      for u in ""${CAND_KEYS[@]}""; do
        if [[ ""$CIS_DRYRUN"" == ""1"" ]]; then
          log ""DRYRUN: would attempt to remove package owning $u (fallback: mask)""
        else
          if ! do_remove ""$u""; then
            # fallback to masking
            do_mask ""$u""
            log ""Masked (fallback): $u""
          else
            log ""Removed owning package of: $u""
          fi
        fi
      done
      ;;
    *)
      echo ""ERROR: Unknown CIS_MODE='$CIS_MODE' (use audit|mask|remove)"" >&2
      exit 1
      ;;
  esac
fi

# 9) Verification: ensure no candidate is left enabled/active (for mask/remove modes)
if [[ ""$CIS_MODE"" != ""audit"" ]]; then
  systemctl daemon-reload >/dev/null 2>&1 || true
  for u in ""${CAND_KEYS[@]}""; do
    # Skip verification for DRYRUN
    [[ ""$CIS_DRYRUN"" == ""1"" ]] && continue

    if systemctl list-unit-files | awk -v U=""$u"" '$1==U{print $2}' | grep -qvE 'masked|disabled|^$'; then
      log ""FAIL: $u remains enabled""
      FAIL=1
    fi
    if systemctl is-active ""$u"" >/dev/null 2>&1; then
      log ""FAIL: $u remains active""
      FAIL=1
    fi
  done
fi

# 10) Final status
if [[ ""$CIS_MODE"" == ""audit"" ]]; then
  if [[ ""${#CAND_KEYS[@]}"" -gt 0 ]]; then
    echo ""OK: Audit completed. Review ${LOG_FILE} and adjust ALLOWLIST/BLOCKLIST. (CIS 2.4)""
    exit 0
  else
    echo ""OK: No nonessential services found (CIS 2.4)""
    exit 0
  fi
else
  if [[ ""$CIS_DRYRUN"" == ""1"" ]]; then
    echo ""OK: DRYRUN completed for mode='${CIS_MODE}'. See ${LOG_FILE}. (CIS 2.4)""
    exit 0
  elif [[ $FAIL -eq 0 ]]; then
    echo ""OK: Nonessential services ${CIS_MODE}d as per policy (CIS 2.4)""
    exit 0
  else
    echo ""FAIL: Some services remain enabled/active. See ${LOG_FILE}.""
    exit 1
  fi
fi"
