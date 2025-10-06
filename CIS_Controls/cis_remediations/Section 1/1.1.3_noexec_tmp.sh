"#!/usr/bin/env bash
# 1.1.3 - Ensure noexec option set on /tmp partition (Oracle Linux 7)
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

# Helper: ensure an option exists in a comma list (awk-rewrite of 4th field)
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

# 2) Prefer systemd tmp.mount if present (OL7 uses systemd)
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
  # Use a drop-in managed file at /etc/systemd/system/tmp.mount (preferred) so edits persist
  TARGET=""/etc/systemd/system/tmp.mount""
  mkdir -p ""$(dirname ""$TARGET"")""
  if [[ -f ""$TARGET"" && ! -f ""${TARGET}.bak-${STAMP}"" ]]; then
    cp -p ""$TARGET"" ""${TARGET}.bak-${STAMP}""
  fi

  # Build/normalize tmp.mount with noexec in Options
  # We do not remove nodev/nosuid if already present; we only enforce noexec for this control.
  cat > ""$TARGET"" <<'EOF'
[Unit]
Description=Temporary Directory
Documentation=man:hier(7)

[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
# Keep mode and strictatime; ensure noexec present (CIS 1.1.3)
Options=mode=1777,strictatime,noexec

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl --now unmask tmp.mount 2>/dev/null || true
  systemctl enable tmp.mount
  systemctl restart tmp.mount

else
  # 3) Fallback: /etc/fstab path — ensure /tmp line exists and has noexec
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/tmp[[:space:]]+' ""$FSTAB""; then
    ensure_opt_in_fstab ""/tmp"" ""noexec""
  else
    # Add a sane tmpfs /tmp entry if none exists (OL7 compatible)
    cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
    echo -e ""tmpfs\t/tmp\ttmpfs\tdefaults,rw,noexec,relatime\t0 0"" >> ""$FSTAB""
  fi
  # Remount runtime
  mount -o remount,noexec /tmp 2>/dev/null || mount /tmp || true
fi

# 4) Verify runtime + persistence
FAIL=0
# runtime mount exists
if ! findmnt -n /tmp >/dev/null 2>&1; then
  echo ""FAIL: /tmp not mounted.""
  FAIL=1
else
  # runtime must include noexec
  findmnt -no OPTIONS /tmp | grep -qw noexec || { echo ""FAIL: /tmp missing noexec at runtime.""; FAIL=1; }
fi

# persistence check: either systemd tmp.mount contains noexec OR fstab has it
PERSIST_OK=0
if systemctl cat tmp.mount >/dev/null 2>&1; then
  if systemctl cat tmp.mount | awk '/^\[Mount\]/{inm=1} inm && /^Options=/{ if ($0 ~ /(^|,)noexec(,|$)/) ok=1 } END{exit ok?0:1}'; then
    PERSIST_OK=1
  fi
fi
if [[ $PERSIST_OK -eq 0 ]]; then
  if grep -Eq '^[[:space:]]*[^#]+[[:space:]]+/tmp[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]*noexec[^[:space:]]*' ""$FSTAB""; then
    PERSIST_OK=1
  fi
fi

if [[ $PERSIST_OK -eq 0 ]]; then
  echo ""FAIL: Persistence not ensured (noexec not found in tmp.mount or /etc/fstab).""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /tmp has noexec at runtime and persistently configured (CIS 1.1.3).""
  exit 0
else
  exit 1
fi"
