"#!/usr/bin/env bash
# 1.2.3 - Ensure gpgcheck is globally activated (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""
YUM_CONF=""/etc/yum.conf""
REPO_DIR=""/etc/yum.repos.d""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

backup_once() {
  local f=""$1""
  [[ -f ""$f"" && ! -f ""${f}.bak-${STAMP}"" ]] && cp -p ""$f"" ""${f}.bak-${STAMP}""
}

# 2) Enforce gpgcheck=1 in /etc/yum.conf [main]
backup_once ""$YUM_CONF""
# If a [main] section exists, set/replace gpgcheck therein; otherwise create one.
awk '
BEGIN { inmain=0; seen=0 }
# Track section headers
/^[[:space:]]*\[/ {
  if (inmain && !seen) { print ""gpgcheck=1""; seen=1 }
  inmain = ($0 ~ /^\s*\[main\]\s*$/)
  print; next
}
{
  if (inmain) {
    if ($0 ~ /^[[:space:]]*gpgcheck[[:space:]]*=/) { print ""gpgcheck=1""; seen=1; next }
  }
  print
}
END {
  if (!inmain && !seen) {
    print ""[main]""
    print ""gpgcheck=1""
  } else if (inmain && !seen) {
    print ""gpgcheck=1""
  }
}
' ""$YUM_CONF"" > ""${YUM_CONF}.new""
mv ""${YUM_CONF}.new"" ""$YUM_CONF""

# 3) Enforce gpgcheck=1 inside each [repo] section of every .repo file
shopt -s nullglob
REPO_FILES=(""$REPO_DIR""/*.repo)

for rf in ""${REPO_FILES[@]}""; do
  backup_once ""$rf""
  awk '
  BEGIN { inrepo=0; seen=0 }
  # On new section header, if the previous section lacked gpgcheck, emit it before switching
  /^[[:space:]]*\[/ {
    if (inrepo && !seen) print ""gpgcheck=1""
    inrepo=1; seen=0
    print; next
  }
  {
    if (inrepo && $0 ~ /^[[:space:]]*gpgcheck[[:space:]]*=/) {
      print ""gpgcheck=1""; seen=1; next
    }
    print
  }
  END {
    if (inrepo && !seen) print ""gpgcheck=1""
  }
  ' ""$rf"" > ""${rf}.new""
  mv ""${rf}.new"" ""$rf""
done

# 4) Verification
FAIL=0

# 4a) yum.conf [main] must have gpgcheck=1
if ! awk '
  BEGIN { inmain=0; ok=0 }
  /^[[:space:]]*\[/ { inmain=($0 ~ /^\s*\[main\]\s*$/); next }
  inmain && /^[[:space:]]*gpgcheck[[:space:]]*=/ {
    if ($0 ~ /=\s*1\s*$/) ok=1
  }
  END { exit ok?0:1 }
' ""$YUM_CONF""; then
  echo ""FAIL: /etc/yum.conf [main] does not have gpgcheck=1""
  FAIL=1
fi

# 4b) Every repo section line with gpgcheck must be =1; also ensure no repo sections lack the key
for rf in ""${REPO_FILES[@]}""; do
  # any gpgcheck != 1 ?
  if awk 'tolower($0) ~ /^[[:space:]]*gpgcheck[[:space:]]*=/ && $0 !~ /=\s*1\s*$/ { exit 0 } END{ exit 1 }' ""$rf""; then
    echo ""FAIL: $rf contains gpgcheck not equal to 1""
    FAIL=1
  fi
  # any section without a gpgcheck after our pass?
  if awk '
    BEGIN { inrepo=0; has=0; bad=0 }
    /^[[:space:]]*\[/ { if (inrepo && !has) bad=1; inrepo=1; has=0; next }
    inrepo && /^[[:space:]]*gpgcheck[[:space:]]*=/ { has=1 }
    END { if (inrepo && !has) bad=1; exit bad?0:1 }
  ' ""$rf""; then
    echo ""FAIL: $rf has a repo section without gpgcheck=1""
    FAIL=1
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: gpgcheck=1 globally enforced in /etc/yum.conf and all repo sections (CIS 1.2.3).""
  exit 0
else
  exit 1
fi"
