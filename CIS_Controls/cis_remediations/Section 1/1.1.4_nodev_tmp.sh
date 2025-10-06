"#!/usr/bin/env bash
# 1.1.4 - Ensure nodev option set on /tmp partition (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""
FSTAB=""/etc/fstab""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# Helper: ensure an option exists in the /etc/fstab 4th field for a mountpoint
ensure_opt_in_fstab() {
  local mp=""$1"" opt=""$2""
  cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
  awk -v mp=""$mp"" -v opt=""$opt"" '
    BEGIN{OFS=""\t"";}
    /^[[:space:]]*($|#)/{print; next}
    $2==mp {
      n=split($4,a,"",""); has=0
      for(i=1;i<=n;i++) if(a[i]==opt) has=1
      if(!has){ if($4==""""||$4==""-"") $4=opt; else $4=$4"",""opt }
      print; next
    }
    {print}
  ' ""$FSTAB"" > ""${FSTAB}.new""
  if ! cmp -s ""$FSTAB"" ""${FSTAB}.new""; then mv ""${FSTAB}.new"" ""$FSTAB""; else rm -f ""${FSTAB}.new""; fi
}

# 2) Prefer systemd tmp.mount if present
UNIT_CANDIDATES=(
  ""/etc/systemd/system/tmp.mount""
  ""/etc/systemd/system/local-fs.target.wants/tmp.mount""
  ""/usr/lib/systemd/system/tmp.mount""
)

UNIT=""""
for c in ""${UNIT_CANDIDATES[@]}""; do
  [[ -e ""$c"" ]] && { UNIT=""$c""; break; }
done

if [[ -n ""$UNIT"" ]]; then
  # Normalize to a managed file at /etc/systemd/system/tmp.mount (so changes persist)
  TARGET=""/etc/systemd/system/tmp.mount""
  mkdir -p ""$(dirname ""$TARGET"")""
  if [[ -f ""$TARGET"" && ! -f ""${TARGET}.bak-${STAMP}"" ]]; then
    cp -p ""$TARGET"" ""${TARGET}.bak-${STAMP}""
  fi

  # Keep minimal required settings for this control: ensure nodev present
  cat > ""$TARGET"" <<'EOF'
[Unit]
Description=Temporary Directory
Documentation=man:hier(7)

[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
# Enforce nodev for CIS 1.1.4 (noexec/nosuid may be managed by other controls)
Options=mode=1777,strictatime,nodev

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl --now unmask tmp.mount 2>/dev/null || true
  systemctl enable tmp.mount
  systemctl restart tmp.mount

else
  # 3) Fallback: use /etc/fstab — ensure /tmp has nodev
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/tmp[[:space:]]+' ""$FSTAB""; then
    ensure_opt_in_fstab ""/tmp"" ""nodev""
  else
    # Add a sane tmpfs entry if none exists
    cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
    echo -e ""tmpfs\t/tmp\ttmpfs\tdefaults,rw,nodev,relatime\t0 0"" >> ""$FSTAB""
  fi
  # Remount runtime
  mount -o remount,nodev /tmp 2>/dev/null || mount /tmp || true
fi

# 4) Verify runtime
FAIL=0
if ! findmnt -n /tmp >/dev/null 2>&1; then
  echo ""FAIL: /tmp not mounted.""
  FAIL=1
else
  findmnt -no OPTIONS /tmp | grep -qw nodev || { echo ""FAIL: /tmp missing nodev at runtime.""; FAIL=1; }
fi

# 5) Verify persistence (systemd tmp.mount OR /etc/fstab)
PERSIST_OK=0
if systemctl cat tmp.mount >/dev/null 2>&1; then
  if systemctl cat tmp.mount | awk '/^\[Mount\]/{inm=1} inm && /^Options=/{ if ($0 ~ /(^|,)nodev(,|$)/) ok=1 } END{exit ok?0:1}'; then
    PERSIST_OK=1
  fi
fi
if [[ $PERSIST_OK -eq 0 ]]; then
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/tmp[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]*nodev[^[:space:]]*' ""$FSTAB""; then
    PERSIST_OK=1
  fi
fi

if [[ $PERSIST_OK -eq 0 ]]; then
  echo ""FAIL: Persistence not ensured (nodev not found in tmp.mount or /etc/fstab).""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /tmp has nodev at runtime and persistently configured (CIS 1.1.4).""
  exit 0
else
  exit 1
fi"
