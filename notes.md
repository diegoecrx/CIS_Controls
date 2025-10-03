# CIS Benchmark Orchestrator
- **Purpose**
  - Provide a master Bash script `cis_main.sh` that:
    - Validates elevated privileges (root).
    - Ensures progress tracking via `cis_progress.log`.
    - Presents hierarchical menus (chapters → subchapters).
    - Renders per-item status: `[complete]` or `[pending]`.
    - Executes remediation sub-scripts in `cis_remediations/` and logs backup/execution outcomes.

---

## Directory Layout

- Root folder:
  - `/CIS_Benchmark/`
    - `cis_main.sh` (master menu/orchestrator)
    - `cis_progress.log` (created if missing)
    - `/cis_remediations/` (one bash per recommendation/control)
      - `1.1.12_noexec.sh`
      - `1.1.13_nodev.sh`
      - `1.1.14_nosuid.sh`
      - `...` (all other items)

---

## Privilege Requirement

- `require_root()` must:
  - Exit with a clear message if `$EUID != 0`.
  - Continue if running as root.

---

## Progress Tracking (Log)

- **File**: `/CIS_Benchmark/cis_progress.log`
- **Record format** (CSV-like, one line per attempt):
  - `UTC_TIMESTAMP,CONTROL_ID,CONTROL_NAME,ACTION,RESULT,MESSAGE`
- **Fields**
  - `ACTION`: `backup` or `execute`
  - `RESULT`: `success` or `fail`
- **Examples**
  - `2025-10-03T03:10:45Z,1.1.12,Ensure /var/tmp noexec,backup,success,"/etc/fstab saved to /backup/fstab_20251003_031045"`
  - `2025-10-03T03:10:48Z,1.1.12,Ensure /var/tmp noexec,execute,fail,"mount remount returned 32"`

---

## Status Computation

- **[complete]**
  - Latest `execute` event for the control has `RESULT=success`.
- **[pending]**
  - No `execute` record exists **or** the last `execute` was not successful.

---

## Menu Flow (Step 2 & Step 3)

- **Main Menu**
  - `1` Initial Setup
  - `2` Services
  - `3` Network Configuration
  - `4` Logging and Auditing
  - `5` Access, Authentication and Authorization
  - `6` System Maintenance
  - `8` Exit
- **Behavior**
  - Selecting `1–6` prints the respective sub-menu.
  - Each (sub)menu line includes a status badge `[complete]/[pending]`.
- **Sub-menu Options**
  - `1 - return` (go back to main menu)
  - `2 - remediate` (invokes Step 4)

---

## Sub-menu Content (by Section)

- **1 Initial Setup**
  - 1.1 Filesystem Configuration
  - 1.2 Configure Software Updates
  - 1.3 Filesystem Integrity Checking
  - 1.4 Secure Boot Settings
  - 1.5 Additional Process Hardening
  - 1.6 Mandatory Access Control
  - 1.7 Command Line Warning Banners
  - 1.8 GNOME Display Manager

- **2 Services**
  - 2.1 inetd Services
  - 2.2 Special Purpose Services
  - 2.3 Service Clients
  - 2.4 Ensure nonessential services are removed or masked (Manual)

- **3 Network Configuration**
  - 3.1 Disable unused network protocols and devices
  - 3.2 Network Parameters (Host Only)
  - 3.3 Network Parameters (Host and Router)
  - 3.4 Uncommon Network Protocols
  - 3.5 Firewall Configuration

- **4 Logging and Auditing**
  - 4.1 Configure System Accounting (auditd)
  - 4.2 Configure Logging

- **5 Access, Authentication and Authorization**
  - 5.1 Configure time-based job schedulers
  - 5.2 Configure sudo
  - 5.3 Configure SSH Server
  - 5.4 Configure PAM
  - 5.5 User Accounts and Environment
  - 5.6 Ensure root login is restricted to system console (Manual)
  - 5.7 Ensure access to the su command is restricted (Automated)

- **6 System Maintenance**
  - 6.1 System File Permissions
  - 6.2 User and Group Settings

---

## Remediation Invocation (Step 4)

- **Mapping**
  - Resolve `CONTROL_ID → remediation script`:
    - Preferred: explicit map (e.g., `1.1.12 → cis_remediations/1.1.12_noexec.sh`).
    - Fallback: heuristic file pattern `cis_remediations/<CONTROL_ID>_*.sh` (take the first match).
- **Backup Phase**
  - Performed either centrally in the master script or inside the remediation script.
  - Log `backup` with `success/fail` and brief message (destination path or error).
- **Execution Phase**
  - Invoke remediation with `bash`.
  - Capture exit code and stdout/stderr.
  - Log `execute` with `success` (exit 0) or `fail` (non-zero).
- **Post-Execution**
  - Recompute statuses and redraw the current menu.

---

## Error Handling

- Validate that the remediation script exists and is executable.
- Handle user cancellations gracefully (do not log `execute` on cancel).
- Sanitize and re-prompt on invalid selections.
- Optional timeouts to stop long-running scripts and log `fail`.

---

## I/O & UX

- Clear terminal between screens.
- Always display:
  - Base directory path.
  - Log file path.
- Ask for explicit confirmation before executing a remediation.

---

## Status Semantics — Comparison Table

| Aspect           | `[complete]`                                  | `[pending]`                                            |
|------------------|-----------------------------------------------|--------------------------------------------------------|
| Definition       | Latest `execute` action succeeded             | No `execute` record or latest `execute` not successful |
| Log dependency   | Requires ≥1 successful `execute`              | Any other state (none/backup-only/last failure)        |
| Update trigger   | Successful remediation run                    | New failures, no runs, or only backup completed        |
| Visual cue       | Shown next to each item in menus              | Shown until a successful `execute` is recorded         |

---
