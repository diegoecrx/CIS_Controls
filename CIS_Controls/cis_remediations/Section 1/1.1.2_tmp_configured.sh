"#!/usr/bin/env bash
# 1.1.2 - Ensure /tmp is configured
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1     # Level 2 profiles inherit Level 1 items
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

UNIT_DIR=""/etc/systemd/system""
UNIT=""$UNIT_DIR/tmp.mount""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Create/overwrite systemd tmp.mount with secure options
mkdir -p ""$UNIT_DIR""
if [[ -f ""$UNIT"" && ! -f ""$UNIT.bak-$STAMP"" ]]; then
  cp -p ""$UNIT"" ""$UNIT.bak-$STAMP""
fi

cat > ""$UNIT"" <<'EOF'
[Unit]
Description=Temporary Directory
Documentation=man:hier(7)

[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,strictatime,nodev,nosuid,noexec

[Install]
WantedBy=multi-user.target
EOF

# 3) Activate (unmask, enable, reload, (re)start)
systemctl daemon-reload
systemctl --now unmask tmp.mount 2>/dev/null || true
systemctl enable tmp.mount
systemctl restart tmp.mount

# 4) Verify mount exists and has required options
FAIL=0
if ! findmnt -n /tmp >/dev/null 2>&1; then
  echo ""FAIL: /tmp not mounted.""
  FAIL=1
else
  for opt in nodev nosuid noexec; do
    if ! findmnt -no OPTIONS /tmp | grep -qw ""$opt""; then
      echo ""FAIL: /tmp missing $opt""
      FAIL=1
    fi
  done
fi

# 5) (Optional) If systemd not available, try fstab path (best-effort, no overwrite)
if [[ $FAIL -ne 0 && ! -d /run/systemd/system ]]; then
  FSTAB=""/etc/fstab""
  cp -p ""$FSTAB"" ""${FSTAB}.bak-$STAMP""
  if grep -Eq '^[[:space:]]*tmpfs[[:space:]]+/tmp[[:space:]]+tmpfs' ""$FSTAB""; then
    # ensure options present on existing tmpfs /tmp entry
    awk '
      BEGIN { OFS=""\t"" }
      /^[[:space:]]*tmpfs[[:space:]]+\/tmp[[:space:]]+tmpfs/ {
        n=split($4,a,"",""); have_dev=have_suid=have_exec=0
        for(i=1;i<=n;i++){ if(a[i]==""nodev"")have_dev=1; if(a[i]==""nosuid"")have_suid=1; if(a[i]==""noexec"")have_exec=1 }
        if(!have_dev)  $4=($4==""""||$4==""-""?""nodev"":$4"",nodev"")
        if(!have_suid) $4=($4==""""||$4==""-""?""nosuid"":$4"",nosuid"")
        if(!have_exec) $4=($4==""""||$4==""-""?""noexec"":$4"",noexec"")
      }
      { print $0 }
    ' ""$FSTAB"" > ""${FSTAB}.new""
    mv ""${FSTAB}.new"" ""$FSTAB""
  else
    # add a new entry
    echo -e ""tmpfs\t/tmp\ttmpfs\tdefaults,rw,nosuid,nodev,noexec,relatime\t0 0"" >> ""$FSTAB""
  fi
  mount -o remount,noexec,nodev,nosuid /tmp 2>/dev/null || mount /tmp || true
  # re-verify
  FAIL=0
  findmnt -n /tmp >/dev/null 2>&1 || { echo ""FAIL: /tmp not mounted (fstab path).""; FAIL=1; }
  for opt in nodev nosuid noexec; do
    findmnt -no OPTIONS /tmp | grep -qw ""$opt"" || { echo ""FAIL: /tmp missing $opt (fstab path)""; FAIL=1; }
  done
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /tmp configured with nodev,nosuid,noexec (CIS 1.1.2).""
  exit 0
else
  exit 1
fi"
