"#!/usr/bin/env bash
# 1.2.1 - Ensure GPG keys are configured (Manual) - Oracle Linux 7
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

REPO_DIR=""/etc/yum.repos.d""
FSTAB=""/etc/fstab"" # not used, placeholder for consistency
FAIL=0

# 1) Require root (read-only audit still prefers root for consistent access)
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root for complete results."" >&2
  exit 1
fi

# 2) Preconditions
shopt -s nullglob
REPO_FILES=(""$REPO_DIR""/*.repo)
if (( ${#REPO_FILES[@]} == 0 )); then
  echo ""FAIL: No repo files in $REPO_DIR""
  exit 1
fi

# 3) Audit: For each enabled repo, require gpgcheck=1 and gpgkey= present.
#    If gpgkey points to a local file (file:// or absolute path), verify it exists.
printf ""\n== Repo GPG Audit ==\n""
printf ""%-30s | %-7s | %-9s | %-6s | %s\n"" ""REPO_ID"" ""ENABLED"" ""GPGCHECK"" ""KEY_OK"" ""GPGKEY (first)""
printf -- ""-------------------------------+---------+-----------+--------+------------------------------\n""

parse_repo_file() {
  awk -v file=""$1"" '
    BEGIN{repo=""""; en=""""; gpc=""""; gpk=""""; OFS=""|"" }
    /^\s*\[/ { 
      if (repo!="""") print repo,en,gpc,gpk;
      repo=$0; sub(/^\s*\[/,"""",repo); sub(/\]\s*$/,"""",repo); en=gpc=gpk="""";
      next
    }
    /^[[:space:]]*enabled\s*=/ { en=$0; sub(/^[^=]*=/,"""",en); gsub(/[[:space:]]/,"""",en) }
    /^[[:space:]]*gpgcheck\s*=/ { gpc=$0; sub(/^[^=]*=/,"""",gpc); gsub(/[[:space:]]/,"""",gpc) }
    /^[[:space:]]*gpgkey\s*=/ { 
      gpk=$0; sub(/^[^=]*=/,"""",gpk); sub(/^[[:space:]]*/,"""",gpk); sub(/[[:space:]]*$/,"""",gpk)
    }
    END{ if (repo!="""") print repo,en,gpc,gpk; }
  ' ""$1""
}

while IFS='|' read -r REPO_ID ENABLED GPGCHECK GPGKEYS || [[ -n ""${REPO_ID:-}"" ]]; do
  [[ -z ""${REPO_ID:-}"" ]] && continue

  # Only consider enabled repos (enabled=1)
  if [[ ""${ENABLED:-0}"" != ""1"" ]]; then
    printf ""%-30s | %-7s | %-9s | %-6s | %s\n"" ""$REPO_ID"" ""${ENABLED:-0}"" ""${GPGCHECK:-}"" ""-"" ""-""
    continue
  fi

  KEY_FIRST=""$(printf ""%s\n"" ""$GPGKEYS"" | awk '{print $1}')""
  KEY_OK=""-""

  # Check gpgcheck
  if [[ ""${GPGCHECK:-0}"" != ""1"" ]]; then
    FAIL=1
  fi

  # Check gpgkey presence
  if [[ -z ""${KEY_FIRST}"" ]]; then
    KEY_OK=""NO""
    FAIL=1
  else
    # If local file path, verify existence
    if [[ ""$KEY_FIRST"" =~ ^file:// ]]; then
      LOCAL_PATH=""${KEY_FIRST#file://}""
      if [[ -f ""$LOCAL_PATH"" ]]; then KEY_OK=""YES""; else KEY_OK=""NO""; FAIL=1; fi
    elif [[ ""$KEY_FIRST"" =~ ^/ ]]; then
      if [[ -f ""$KEY_FIRST"" ]]; then KEY_OK=""YES""; else KEY_OK=""NO""; FAIL=1; fi
    else
      # http(s) or other scheme — cannot fetch here; mark as UNKNOWN
      KEY_OK=""UNK""
    fi
  fi

  printf ""%-30s | %-7s | %-9s | %-6s | %s\n"" ""$REPO_ID"" ""$ENABLED"" ""${GPGCHECK:-}"" ""$KEY_OK"" ""${KEY_FIRST:-""-""}""

done < <(for f in ""${REPO_FILES[@]}""; do parse_repo_file ""$f""; done)

# 4) Show installed RPM GPG pubkeys (informational)
printf ""\n== Installed RPM GPG Public Keys ==\n""
rpm -qa gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' 2>/dev/null || true

# 5) Result and manual guidance
echo
if [[ $FAIL -eq 0 ]]; then
  echo ""OK: All enabled repos have gpgcheck=1 and present GPG key references. Manual validation of key trust/source is still required (CIS 1.2.1).""
  exit 0
else
  cat <<'EOT'
FAIL: One or more enabled repos are missing gpgcheck=1 and/or a usable gpgkey.
Manual remediation per site policy:
  - Ensure each enabled repo in /etc/yum.repos.d/*.repo has:
      gpgcheck=1
      gpgkey=file:///etc/pki/rpm-gpg/<your-key>.gpg   (or approved https URL)
  - Import trusted keys:
      rpm --import /etc/pki/rpm-gpg/<your-key>.gpg
  - Validate key provenance, fingerprint, and expiration against site policy.
EOT
  exit 1
fi"
