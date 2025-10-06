#!/usr/bin/env bash
set -euo pipefail

# Goal: Ensure logging is properly configured by adding recommended facility filters to rsyslog.
# Filename: 4.2.1.4_rsyslog_logging.sh
# Applicability: Level 1 for both Server and Workstation (manual control)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Run as root." >&2
  exit 1
fi

# Recommended rsyslog configuration lines
read -r -d '' RSYSLOG_LINES <<'LINES'
*.emerg :omusrmsg:*
auth,authpriv.*                    /var/log/secure
mail.*                             -/var/log/mail
mail.info                          -/var/log/mail.info
mail.warning                       -/var/log/mail.warn
mail.err                           /var/log/mail.err
news.crit                          -/var/log/news/news.crit
news.err                           -/var/log/news/news.err
news.notice                        -/var/log/news/news.notice
LINES

update_rsyslog_file() {
  local file=$1
  [[ -f "$file" && ! -f "${file}.bak" ]] && cp "$file" "${file}.bak"
  # Ensure each recommended line is present
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    grep -Fq "$line" "$file" || echo "$line" >> "$file"
  done <<< "$RSYSLOG_LINES"
}

main_conf="/etc/rsyslog.conf"
update_rsyslog_file "$main_conf"

for conf in /etc/rsyslog.d/*.conf; do
  [[ -f "$conf" ]] || continue
  update_rsyslog_file "$conf"
done

# Reload rsyslog to apply changes
systemctl reload rsyslog 2>/dev/null || true

# Verification: ensure lines exist in the main configuration file
ok=1
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  grep -Fq "$line" "$main_conf" || ok=0
done <<< "$RSYSLOG_LINES"

if [[ $ok -eq 1 ]]; then
  echo "OK: Logging filters configured in rsyslog (CIS 4.2.1.4)."
  exit 0
else
  echo "FAIL: Some logging filters are missing in rsyslog configuration." >&2
  exit 1
fi