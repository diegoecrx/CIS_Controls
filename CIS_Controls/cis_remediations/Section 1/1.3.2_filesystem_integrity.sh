"#!/usr/bin/env bash
# 1.3.2 - Ensure filesystem integrity is regularly checked (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Config
AIDE_BIN=""/usr/sbin/aide""
SERVICE=""/etc/systemd/system/aidecheck.service""
TIMER=""/etc/systemd/system/aidecheck.timer""
CRON_D=""/etc/cron.d/aide_check""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Verify AIDE present (scheduling without aide is pointless)
if ! command -v ""$AIDE_BIN"" >/dev/null 2>&1; then
  echo ""FAIL: $AIDE_BIN not found. Run CIS 1.3.1 to install and initialize AIDE first.""
  exit 1
fi

# 3) Prefer systemd timer on OL7
if [[ -d /run/systemd/system ]]; then
  # Backup existing units once
  [[ -f ""$SERVICE"" && ! -f ""${SERVICE}.bak-${STAMP}"" ]] && cp -p ""$SERVICE"" ""${SERVICE}.bak-${STAMP}""
  [[ -f ""$TIMER""   && ! -f ""${TIMER}.bak-${STAMP}""   ]] && cp -p ""$TIMER""   ""${TIMER}.bak-${STAMP}""

  # Create/overwrite service
  cat > ""$SERVICE"" <<'EOF'
[Unit]
Description=AIDE Check

[Service]
Type=simple
ExecStart=/usr/sbin/aide --check
EOF

  # Create/overwrite timer (daily at 05:00)
  cat > ""$TIMER"" <<'EOF'
[Unit]
Description=Aide check every day at 5AM

[Timer]
OnCalendar=*-*-* 05:00:00
Unit=aidecheck.service
Persistent=true

[Install]
WantedBy=timers.target
EOF

  chown root:root ""$SERVICE"" ""$TIMER""
  chmod 0644 ""$SERVICE"" ""$TIMER""

  systemctl daemon-reload
  systemctl enable aidecheck.service >/dev/null 2>&1 || true
  systemctl enable --now aidecheck.timer

  # 4) Verify systemd path
  FAIL=0
  systemctl is-enabled aidecheck.timer >/dev/null 2>&1 || { echo ""FAIL: aidecheck.timer not enabled.""; FAIL=1; }
  systemctl is-active  aidecheck.timer >/dev/null 2>&1 || { echo ""FAIL: aidecheck.timer not active.""; FAIL=1; }
  systemctl cat aidecheck.service 2>/dev/null | grep -qE '^\s*ExecStart=\s*/usr/sbin/aide\s+--check(\s|$)' \
    || { echo ""FAIL: aidecheck.service ExecStart mismatch.""; FAIL=1; }

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: AIDE daily check scheduled via systemd timer at 05:00 (CIS 1.3.2).""
    exit 0
  else
    exit 1
  fi
else
  # 5) Fallback to cron if systemd not available
  echo ""INFO: systemd not detected; using cron fallback.""
  printf '0 5 * * * root %s --check\n' ""$AIDE_BIN"" > ""$CRON_D""
  chown root:root ""$CRON_D""
  chmod 0644 ""$CRON_D""

  # Verify cron path
  if grep -q -- ""$AIDE_BIN --check"" ""$CRON_D""; then
    echo ""OK: AIDE daily check scheduled via cron at 05:00 (CIS 1.3.2).""
    exit 0
  else
    echo ""FAIL: Could not write cron entry at $CRON_D.""
    exit 1
  fi
fi"
