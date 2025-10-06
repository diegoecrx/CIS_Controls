You are to generate CIS hardening **Bash scripts for Oracle Linux 7** from a spreadsheet.

Read this carefully and follow it exactly:

Context
- This project is OS hardening for **Oracle Linux 7** only.
- You must read and interpret each spreadsheet row *before* writing code.
- Always implement the **CIS-recommended commands first** (from the Remediation column). Do not search the web unless I later ask for enhancements.

Spreadsheet columns (exact meaning)
- Column 1: **Control** → the CIS control id and title (e.g., `4.1.1.1 Ensure auditd is installed (Automated)`).
- Column 2: **Profile Applicability** → which Levels/Profiles apply (e.g., “Level 1 - Server”, “Level 2 - Workstation”).
- Column 3: **Remediation** → the exact CIS-recommended action(s) and command(s) to apply.

What to output for each row I send
- **One script per row** (do NOT bundle multiple rows).
- English only. Minimal bullets + a single code block.
- **Filename rule**: `<control-number>_<short-name>.sh`
  - Short name = primary subject from the Remediation (e.g., `auditd`, `tmp_nodev`, `gpgcheck_global`, `grub_password`, `cramfs`, etc.).
  - Example: “4.1.1.1 Ensure auditd is installed (Automated)” → `4.1.1.1_auditd.sh`.

Script structure & style (mandatory)
- Start with a brief bullet summary: **Goal**, **Filename**, **Applicability flags table** (if useful).
- Then output **one** Bash code block with:
  - Shebang + strict mode: `#!/usr/bin/env bash` and `set -euo pipefail`.
  - **Metadata flags** (variables only, not enforced):
    - `APPLIES_L1` (0/1), `APPLIES_L2` (0/1), `APPLIES_SERVER` (0/1), `APPLIES_WORKSTATION` (0/1).
    - Derive from **Profile Applicability**: if it mentions Level 1 → `APPLIES_L1=1` else 0; Level 2 → `APPLIES_L2=1` else 0; “Server” → `APPLIES_SERVER=1`; “Workstation” → `APPLIES_WORKSTATION=1`.
  - **Root requirement** at the top:
    ```bash
    if [[ $EUID -ne 0 ]]; then echo "ERROR: Run as root." >&2; exit 1; fi
    ```
  - **Backup rule (required)**:
    - For every file you modify, if `<file>.bak` does **not** exist, create it (or use a timestamped `.bak-<YYYYmmddHHMMSS>` if you need multiple edits).  
      Examples: before editing `/boot/grub2/grub.cfg`, ensure `/boot/grub2/grub.cfg.bak` exists (or `.bak-<stamp>`).
  - **Implement the Remediation exactly as written** (create/edit/disable/etc.), adapting command lines into idempotent Bash:
    - Use the explicit CIS commands from the Remediation column (e.g., `yum install ...`, `modprobe -r`, `mount -o remount,...`, `grub2-mkconfig ...`, `dconf update`, etc.).
    - When editing files, prefer **safe, idempotent edits** with `awk/sed` that preserve unrelated content; create files if missing with secure perms.
    - When enabling kernel/sysctl/module settings: write persistent config (`/etc/sysctl.d/*.conf`, `/etc/modprobe.d/*.conf`, `/etc/dconf/db/...`) **and** apply at runtime if applicable.
    - When working with systemd: use drop-ins or unit files under `/etc/systemd/system`, then `systemctl daemon-reload` and `systemctl (enable|restart|mask|stop)` as appropriate.
  - **Verification section**:
    - Verify both **runtime state** (e.g., mount options active, sysctl value set, module unloaded, service masked, etc.) **and persistence** (e.g., config file contains required setting).
    - Set `FAIL=0` and flip to 1 on any failed check; end with:
      - `echo "OK: <concise success> (CIS X.Y.Z)."; exit 0`
      - or `echo "FAIL: <reason>"; exit 1`
  - Scripts must be **idempotent** and **safe to rerun**.

Interpretation specifics
- Read the Remediation text and **convert the described step(s)** into code.  
  Examples:
  - If it says *“Edit /etc/fstab and add nodev to /tmp; remount”* → Write an awk-based edit that ensures the option exists once, then `mount -o remount,...`.
  - If it says *“Edit or create /etc/modprobe.d/<name>.conf and add ‘install <mod> /bin/true’; rmmod <mod>”* → Ensure the line is present (replace existing `install <mod>`), then unload the module.
  - If it says *“Run grub2-setpassword”* or provide PBKDF2 → require env vars for username/hash and write `password_pbkdf2` into `/etc/grub.d/40_custom`, then `grub2-mkconfig`.
  - If it says *“dconf profile + db + dconf update”* → write the files under `/etc/dconf/...` and run `dconf update`.
  - If it says *“yum remove <pkg>”* → stop/disable/mask any related service, then `yum -y remove <pkg>` and verify package absence.
  - If it says *“Manual”* → still produce a script that either performs the safe recommended action or **audits** with a clear pass/fail.

Conventions & guardrails
- Always target **Oracle Linux 7** semantics.
- Use **BIOS/UEFI-aware** grub paths (`/boot/grub2/grub.cfg` vs `/boot/efi/EFI/<vendor>/grub.cfg`) when regenerating configs.
- Use `/etc/sysctl.d/*.conf`, `/etc/modprobe.d/*.conf`, `/etc/dconf/db/*`, `/etc/security/limits.d/*.conf` rather than editing monolithic files when feasible (but obey the Remediation text if it names a specific file).
- Do not promise future actions; everything must happen in the current script output.

Deliverable format for each row I paste
- Bulleted summary (Goal, Filename, Applicability flags table if useful).
- One fenced Bash code block with the full script. No extra chatter.

Example naming
- Control: `4.1.1.1 Ensure auditd is installed (Automated)` → `4.1.1.1_auditd.sh`

Now wait for me to paste the first control row (Control, Profile Applicability, Remediation). For every row, respond with: concise bullets + the script.
