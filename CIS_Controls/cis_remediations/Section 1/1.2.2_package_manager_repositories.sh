"#!/usr/bin/env bash
# 1.2.2 - Ensure package manager repositories are configured (Manual) - Oracle Linux 7
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

REPO_DIR=""/etc/yum.repos.d""
FAIL=0

# 1) Require root for complete access (read-only audit)
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root for complete results."" >&2
  exit 1
fi

# 2) Preconditions
shopt -s nullglob
REPO_FILES=(""$REPO_DIR""/*.repo)
if (( ${#REPO_FILES[@]} == 0 )); then
  echo ""FAIL: No repo files found in $REPO_DIR""
  exit 1
fi

# 3) Parser: list all repos and key attributes
parse_repo_file() {
  # Output: REPO_ID|ENABLED|BASEURL_SET|MIRRORLIST_SET|SSLVERIFY|GPGCHECK|PRIORITY|METALINK_SET|FILE|DOMAIN
  awk -v file=""$1"" '
    function trim(s){ sub(/^[ \t\r\n]+/, """", s); sub(/[ \t\r\n]+$/, """", s); return s }
    /^\s*\[/ {
      if (repo!="""") {
        bu = (baseurl!="""" ? ""1"":""0"")
        ml = (mirrorlist!="""" ? ""1"":""0"")
        me = (metalink!="""" ? ""1"":""0"")
        dm = domain
        print repo ""|"" (enabled==""""?""0"":enabled) ""|"" bu ""|"" ml ""|"" (sslverify==""""?"""":sslverify) ""|"" (gpgcheck==""""?"""":gpgcheck) ""|"" (priority==""""?"""":priority) ""|"" me ""|"" file ""|"" dm
      }
      repo=$0; sub(/^\s*\[/, """", repo); sub(/\]\s*$/, """", repo)
      enabled=gpgcheck=sslverify=priority=""""
      baseurl=mirrorlist=metalink=domain=""""
      next
    }
    /^[[:space:]]*enabled\s*=/   { enabled=trim($0); sub(/^[^=]*=/,"""",enabled); gsub(/[[:space:]]/,"""",enabled) }
    /^[[:space:]]*gpgcheck\s*=/  { gpgcheck=trim($0); sub(/^[^=]*=/,"""",gpgcheck); gsub(/[[:space:]]/,"""",gpgcheck) }
    /^[[:space:]]*sslverify\s*=/ { sslverify=trim($0); sub(/^[^=]*=/,"""",sslverify); gsub(/[[:space:]]/,"""",sslverify) }
    /^[[:space:]]*priority\s*=/  { priority=trim($0); sub(/^[^=]*=/,"""",priority); gsub(/[[:space:]]/,"""",priority) }
    /^[[:space:]]*baseurl\s*=/   { baseurl=trim($0); sub(/^[^=]*=/,"""",baseurl); sub(/^[[:space:]]*/,"""",baseurl); sub(/[[:space:]]*$/,"""",baseurl) }
    /^[[:space:]]*mirrorlist\s*=/ { mirrorlist=trim($0); sub(/^[^=]*=/,"""",mirrorlist); sub(/^[[:space:]]*/,"""",mirrorlist); sub(/[[:space:]]*$/,"""",mirrorlist) }
    /^[[:space:]]*metalink\s*=/  { metalink=trim($0); sub(/^[^=]*=/,"""",metalink); sub(/^[[:space:]]*/,"""",metalink); sub(/[[:space:]]*$/,"""",metalink) }
    END {
      if (repo!="""") {
        bu = (baseurl!="""" ? ""1"":""0"")
        ml = (mirrorlist!="""" ? ""1"":""0"")
        me = (metalink!="""" ? ""1"":""0"")
        # Derive domain for quick visual review (from baseurl/mirrorlist/metalink if http/https)
        url = (baseurl!=""""?baseurl:(mirrorlist!=""""?mirrorlist:metalink))
        if (url ~ /^https?:\/\//) {
          gsub(/^https?:\/\//,"""",url)
          split(url, p, /[\/?]/)
          domain = p[1]
        } else { domain = """" }
        print repo ""|"" (enabled==""""?""0"":enabled) ""|"" bu ""|"" ml ""|"" (sslverify==""""?"""":sslverify) ""|"" (gpgcheck==""""?"""":gpgcheck) ""|"" (priority==""""?"""":priority) ""|"" me ""|"" file ""|"" domain
      }
    }
  ' ""$1""
}

# 4) Header
printf ""%-30s | %-7s | %-3s | %-3s | %-9s | %-8s | %-8s | %-3s | %-25s | %s\n"" \
  ""REPO_ID"" ""ENABLED"" ""BU"" ""ML"" ""SSLVERIFY"" ""GPGCHECK"" ""PRIORITY"" ""ME"" ""FILE"" ""DOMAIN""
printf -- ""-------------------------------+---------+-----+-----+-----------+----------+----------+-----+---------------------------+------------------------------\n""

# 5) Evaluate each repo, flagging common issues
MISSING_CFG=0
DUP_COUNT=0
declare -A SEEN
while IFS='|' read -r REPO_ID ENABLED BU ML SSLV GPGC PRIO ME FILE DOMAIN || [[ -n ""${REPO_ID:-}"" ]]; do
  [[ -z ""${REPO_ID:-}"" ]] && continue

  [[ -n ""${SEEN[$REPO_ID]:-}"" ]] && DUP_COUNT=$((DUP_COUNT+1))
  SEEN[$REPO_ID]=1

  printf ""%-30s | %-7s | %-3s | %-3s | %-9s | %-8s | %-8s | %-3s | %-25s | %s\n"" \
    ""$REPO_ID"" ""${ENABLED:-0}"" ""${BU:-0}"" ""${ML:-0}"" ""${SSLV:-}"" ""${GPGC:-}"" ""${PRIO:-}"" ""${ME:-0}"" ""$(basename ""$FILE"")"" ""${DOMAIN:-}""

  # Findings for enabled repos
  if [[ ""${ENABLED:-0}"" == ""1"" ]]; then
    # must have a baseurl OR mirrorlist OR metalink
    if [[ ""${BU:-0}"" == ""0"" && ""${ML:-0}"" == ""0"" && ""${ME:-0}"" == ""0"" ]]; then
      echo ""FINDING: Enabled repo '$REPO_ID' has no baseurl/mirrorlist/metalink in $FILE""
      MISSING_CFG=1
    fi
    # mirrorlist and baseurl should not both be set (common hygiene)
    if [[ ""${BU:-0}"" == ""1"" && ""${ML:-0}"" == ""1"" ]]; then
      echo ""FINDING: Repo '$REPO_ID' sets BOTH baseurl and mirrorlist; prefer one.""
      FAIL=1
    fi
    # Optional advisory (not enforced here): gpgcheck should be 1
    if [[ ""${GPGC:-}"" != ""1"" ]]; then
      echo ""ADVISORY: Repo '$REPO_ID' does not have gpgcheck=1 (covered by CIS 1.2.1).""
    fi
  fi
done < <(for f in ""${REPO_FILES[@]}""; do parse_repo_file ""$f""; done)

# 6) Try to show yum repolist (informational; network not required)
echo
yum -q repolist enabled 2>/dev/null || true

# 7) Result
echo
if (( MISSING_CFG == 0 )) && (( DUP_COUNT == 0 )); then
  echo ""OK: Repository definitions present and structurally configured. Review domains and policies for compliance (CIS 1.2.2 is manual).""
  exit 0
else
  [[ $DUP_COUNT -gt 0 ]] && echo ""FINDING: Duplicate repo IDs detected: $DUP_COUNT""
  echo ""FAIL: One or more enabled repos lack baseurl/mirrorlist/metalink or other hygiene issues noted above.""
  exit 1
fi"
