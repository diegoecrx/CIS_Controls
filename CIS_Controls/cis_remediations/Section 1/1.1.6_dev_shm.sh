"#!/usr/bin/env bash
# 1.1.6 - Ensure /dev/shm is configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

FSTAB=""/etc/fstab""
STAMP=""$(date +%Y%m%d%H%M%S)""
REQ_OPTS=(noexec nodev nosuid)   # runtime must include these
FSTAB_REQ_OPTS=(defaults noexec nodev nosuid seclabel)  # must persist in /etc/fstab

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure an fstab entry exists and includes required options
cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""

if grep -Eq '^[[:space:]]*tmpfs[[:space:]]+/dev/shm[[:space:]]+tmpfs' ""$FSTAB""; then
  # Update options in existing line: ensure each required fstab option is present
  awk -v mp=""/dev/shm"" '
    BEGIN { OFS=""\t"" }
    /^[[:space:]]*($|#)/ { print; next }
    $2 == mp && $3 == ""tmpfs"" {
      # build a set of options
      split($4, a, "","")
      for (i in a) seen[a[i]] = 1
      # required options
      req[1] = ""defaults""; req[2] = ""noexec""; req[3] = ""nodev""; req[4] = ""nosuid""; req[5] = ""seclabel""
      for (i = 1; i <= 5; i++) if (!seen[req[i]]) list = (list ? list"",""req[i] : req[i])
      $4 = ($4 == """" || $4 == ""-"" ? list : $4 (list ? "","" list : """"))
      print; next
    }
    { print }
  ' ""$FSTAB"" > ""${FSTAB}.new""
else
  # Add a new compliant entry
  {
    cat ""$FSTAB""
    echo -e ""tmpfs\t/dev/shm\ttmpfs\tdefaults,noexec,nodev,nosuid,seclabel\t0 0""
  } > ""${FSTAB}.new""
fi

# Persist the change if any
if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then
  mv ""${FSTAB}.new"" ""$FSTAB""
else
  rm -f ""${FSTAB}.new""
fi

# 3) Remount /dev/shm at runtime with required flags (size can be tuned in fstab if desired)
mount -o remount,noexec,nodev,nosuid /dev/shm 2>/dev/null || mount /dev/shm || true

# 4) Verify
FAIL=0

# 4a) Runtime: mount exists and includes required options
if ! findmnt -n /dev/shm >/dev/null 2>&1; then
  echo ""FAIL: /dev/shm not mounted.""
  FAIL=1
else
  for opt in ""${REQ_OPTS[@]}""; do
    findmnt -no OPTIONS /dev/shm | grep -qw ""$opt"" || { echo ""FAIL: /dev/shm missing runtime option: $opt""; FAIL=1; }
  done
fi

# 4b) Persistence: /etc/fstab entry includes all required fstab options
FSTAB_LINE=""$(awk 'NF && $1 !~ /^#/ && $2==""/dev/shm"" && $3==""tmpfs"" {print $0}' ""$FSTAB"" || true)""
if [[ -z ""$FSTAB_LINE"" ]]; then
  echo ""FAIL: No /etc/fstab entry found for /dev/shm tmpfs.""
  FAIL=1
else
  for opt in ""${FSTAB_REQ_OPTS[@]}""; do
    awk -v o=""$opt"" -v line=""$FSTAB_LINE"" 'BEGIN{ ok=(line ~ ""(^|[[:space:]])[^[:space:]]+[[:space:]]+/dev/shm[[:space:]]+tmpfs[[:space:]]+([^[:space:]]*\\<"" o ""\\>[^[:space:]]*)""); exit ok?0:1 }'
    if [[ $? -ne 0 ]]; then
      echo ""FAIL: fstab /dev/shm entry missing option: $opt""
      FAIL=1
    fi
  done
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /dev/shm configured and mounted with noexec,nodev,nosuid; persisted in /etc/fstab with defaults,noexec,nodev,nosuid,seclabel (CIS 1.1.6).""
  exit 0
else
  exit 1
fi"
