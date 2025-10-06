You are to generate CIS hardening **Bash scripts for Oracle Linux 7** from a spreadsheet.

Scope & delivery
- I will specify **which Section** of the spreadsheet to implement (e.g., “Section 1”).
- You will process **every row in that Section**, outputting **one script per control** (do NOT bundle).
- As each script is created, output it inline (summary + code).
- When the Section is complete, **package all scripts from that Section into a single .zip** and attach it here.

Spreadsheet columns (interpretation)
- Column 1 **Control**: CIS id + title (e.g., `4.1.1.1 Ensure auditd is installed (Automated)`).
- Column 2 **Profile Applicability**: derive metadata flags (L1/L2, Server/Workstation).
- Column 3 **Remediation**: the exact CIS-recommended steps/commands to apply (implement these first).

Filename rule
- `<control-number>_<short-name>.sh`
  - Short name = primary subject from Remediation (e.g., `auditd`, `tmp_nodev`, `gpgcheck_global`, `grub_password`, `cramfs`).
  - Example: `4.1.1.1_auditd.sh`.

Script structure (mandatory, idempotent)
- Start with concise bullets: **Goal**, **Filename**, small applicability flags table (optional).
- Then **one** Bash code block with:
  - Shebang + strict mode:
    - `#!/usr/bin/env bash`
    - `set -euo pipefail`
  - **Metadata flags** (variables only; not enforced):
    - `APPLIES_L1` (0/1), `APPLIES_L2` (0/1), `APPLIES_SERVER` (0/1), `APPLIES_WORKSTATION` (0/1).
      - If Profile mentions “Level 1” → `APPLIES_L1=1`, “Level 2” → `APPLIES_L2=1`; “Server”/“Workstation” likewise.
  - **Root requirement** at top (mandatory):
    ```bash
    if [[ $EUID -ne 0 ]]; then echo "ERROR: Run as root." >&2; exit 1; fi
    ```
  - **Backup rule (mandatory)** before modifying any file:
    - If `<file>.bak` does **not** exist, create it (or a timestamped `.bak-<YYYYmmddHHMMSS>` if repeating).
    - Example: before editing `/boot/grub2/grub.cfg`, ensure `/boot/grub2/grub.cfg.bak` exists.
  - **Implement the Remediation exactly as written** (create/edit/disable/install/remove…), adapted to be **idempotent**:
    - Use the explicit CIS commands from Remediation (`yum install/remove`, `modprobe -r`, `mount -o remount,...`, `grub2-mkconfig`, `dconf update`, etc.).
    - Use safe `awk/sed` edits that preserve unrelated content; create files if missing with secure perms.
    - For systemd, use `/etc/systemd/system` (units/drop-ins) with `systemctl daemon-reload` and appropriate `enable/disable/mask/restart`.
    - Persist kernel/sysctl/module settings with `/etc/sysctl.d/*.conf`, `/etc/modprobe.d/*.conf`, `/etc/dconf/db/*`, `/etc/security/limits.d/*.conf`, etc., **and** apply runtime changes where applicable.
  - **Verification section (mandatory)**:
    - Verify **runtime state** (e.g., mount options present, sysctl set, module unloaded, service masked).
    - Verify **persistence** (config contains required setting).
    - Use `FAIL=0` and set `FAIL=1` on any finding; end with:
      - `echo "OK: … (CIS X.Y.Z)."; exit 0`  → success
      - or `echo "FAIL: …"; exit 1`          → failure

NEW mandatory logging requirements (per Section)
- **Working directory** for scripts will mirror the Section, e.g. `/CIS_Controls/cis_remediations/Section1/`.
- For each Section directory, maintain a **single log file** named `section<NUMBER>.log` (e.g., `section1.log`).
- **On every script run**, append **one line** to the Section log in this exact format:
  - `h:mm AM/PM m/d/YYYY <script_basename> <status>`
  - Example: `4:54 PM 10/6/2025 1.1.12_noexec complete`
- **Status rules**:
  - `complete` → The script’s verification passed (exit 0).
  - `pending`  → The script failed verification / encountered an error / resource missing (exit non-zero).
- **Per-script failure log**:
  - If the script exits non-zero, create (or overwrite) a file named `<script_basename>.log` in the **current directory**, containing the **reason(s)** for failure (captured error/diagnostic text).

Implementation details for logging (use in every script)
- Determine the Section log file automatically from the current directory name:
  - If `$PWD` contains `Section<NUMBER>`, then `SECTION_LOG="section<NUMBER>.log"`.
  - Otherwise default to `section.log`.
- Build a timestamp with 12-hour time and US date:
  ```bash
  ts="$(date +"%-I:%M %p %-m/%-d/%Y")"   # e.g., 4:54 PM 10/6/2025









