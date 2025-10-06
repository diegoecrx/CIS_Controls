You are to generate CIS hardening **Bash scripts for Oracle Linux 7** from a spreadsheet.

Scope & delivery
- I will specify **which section** of the spreadsheet to implement (e.g., “Section 1”).
- You will read **every row in that section**, one by one, and produce **one script per control** (do NOT bundle).
- As you create each script, output it inline (summary + code).
- When the section is complete, **package all scripts from that section into a single .zip** and provide it **in this chat** for download.

Core rules (follow exactly)
- English only. Minimal bullets + a single code block per control.
- **Filename rule**: `<control-number>_<short-name>.sh`
  - Short name = primary subject from the Remediation column (e.g., `auditd`, `tmp_nodev`, `gpgcheck_global`, `grub_password`, `cramfs`).
  - Example: “4.1.1.1 Ensure auditd is installed (Automated)” → `4.1.1.1_auditd.sh`.
- **One script per spreadsheet row**.
- **Oracle Linux 7** semantics only.
- Implement the **CIS-recommended commands first** (from the Remediation column). Do not search the web unless I later ask for enhancements.

Spreadsheet columns (interpretation)
- Column 1 **Control**: CIS control id and title (e.g., `4.1.1.1 Ensure auditd is installed (Automated)`).
- Column 2 **Profile Applicability**: Levels/roles to set flags (e.g., “Level 1 - Server”, “Level 2 - Workstation”).
- Column 3 **Remediation**: Exact recommended steps/commands to apply.

Script structure (mandatory, idempotent)
- Start with concise bullets: **Goal**, **Filename**, and a small applicability flags table (optional).
- Then **one** Bash code block with:
  - Shebang and strict mode:
    - `#!/usr/bin/env bash`
    - `set -euo pipefail`
  - **Metadata flags** (variables only; not enforced):
    - `APPLIES_L1` (0/1), `APPLIES_L2` (0/1), `APPLIES_SERVER` (0/1), `APPLIES_WORKSTATION` (0/1).
    - Derive from Profile Applicability (if it mentions “Level 1” → `APPLIES_L1=1`, etc.).
  - **Root requirement** at top:
    ```bash
    if [[ $EUID -ne 0 ]]; then echo "ERROR: Run as root." >&2; exit 1; fi
    ```
  - **Backup rule (required)**: before modifying any file, ensure a `.bak` exists
    - Example: before editing `/boot/grub2/grub.cfg`, create `/boot/grub2/grub.cfg.bak` if it doesn’t exist (or `.<stamp>` if multiple edits).
  - **Implement the Remediation exactly as written** (create/edit/disable/install/remove…):
    - Use the explicit CIS commands in Remediation (e.g., `yum install/remove`, `modprobe -r`, `mount -o remount,...`, `grub2-mkconfig`, `dconf update`, etc.).
    - Prefer safe, idempotent edits with `awk/sed`; create files if missing with secure perms.
    - For systemd: use `/etc/systemd/system` units/drop-ins and `systemctl daemon-reload` + enable/disable/mask/restart as needed.
    - For persistent kernel/sysctl/module settings: use `/etc/sysctl.d/*.conf`, `/etc/modprobe.d/*.conf`, `/etc/dconf/db/*`, `/etc/security/limits.d/*.conf`, etc., and also apply runtime changes where applicable.
  - **Verification section**:
    - Verify **runtime state** (e.g., mount options active, sysctl value set, module unloaded, service masked).
    - Verify **persistence** (config contains required setting).
    - Use `FAIL=0` and flip to 1 on findings; end with:
      - `echo "OK: … (CIS X.Y.Z)."; exit 0`
      - or `echo "FAIL: …"; exit 1`

Interpretation guidance
- Read each row’s Remediation and translate the steps into idempotent Bash:
  - `fstab` edits + `mount -o remount,...`
  - `/etc/modprobe.d/*.conf` with `install <module> /bin/true` + `rmmod <module>`
  - `grub2-setpassword` / PBKDF2 → write to `/etc/grub.d/40_custom` + `grub2-mkconfig` (BIOS/UEFI aware)
  - `dconf` profile + db + `dconf update`
  - `yum remove <pkg>` (stop/disable/mask related services first)
  - “Manual” controls: produce a safe audit/remediation script that either performs the recommended action or clearly audits and reports pass/fail.

Conventions & guardrails
- BIOS/UEFI aware for grub: choose `/boot/grub2/grub.cfg` or `/boot/efi/EFI/<vendor>/grub.cfg` correctly.
- Keep scripts **idempotent** and safe to rerun.
- No promises of future action: everything happens in the current response.
- After finishing the specified section, **bundle all scripts from that section into a .zip** and attach it here.

Deliverable format per control
- Bulleted summary (Goal, Filename, flags table if useful).
- One fenced Bash code block with the full script—no extra chatter.

I will now specify the **Section** to implement. Generate scripts for every row in that section, outputting each one, and provide a final **.zip** archive of the section’s scripts in this chat.
