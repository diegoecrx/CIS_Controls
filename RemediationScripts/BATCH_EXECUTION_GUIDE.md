# Batch Execution Guide for CIS Remediation Scripts

This guide answers common questions about running multiple remediation scripts and understanding their impact.

## ⚠️ High-Impact Controls That May Affect Access

### 1. Password Policies (Section 1.1.x) - 5 scripts
**May force immediate password changes or prevent weak passwords**

- `1.1.1.ps1` - Enforce password history (24+ passwords)
- `1.1.3.ps1` - Minimum password age (1+ days)
- `1.1.4.ps1` - Minimum password length (14+ characters)
- `1.1.5.ps1` - Password complexity requirements (Enabled)
- `1.1.6.ps1` - Relax minimum password length limits (Enabled)

**⚠️ IMPACT:**
- Users with passwords not meeting requirements will need to change them
- May prevent users from changing passwords too frequently
- Stricter requirements may temporarily lock out users with weak passwords
- **When applied:** Changes take effect at next password change or login

### 2. Account Lockout Policies (Section 1.2.x) - 3 scripts
**Will lock accounts after failed login attempts**

- `1.2.1.ps1` - Account lockout duration (15+ minutes)
- `1.2.2.ps1` - Account lockout threshold (5 failed attempts)
- `1.2.4.ps1` - Reset account lockout counter (15+ minutes)

**⚠️ IMPACT:**
- Legitimate users with wrong passwords will be locked out
- Accounts remain locked for 15 minutes (or until admin unlocks)
- Help desk calls may increase temporarily
- **When applied:** Immediate - affects next failed login attempt

### 3. User Rights Assignment (Section 2.2.x) - 14 scripts
**May prevent users from accessing systems remotely or locally**

Critical controls:
- `2.2.2.ps1` - Access this computer from the network
- `2.2.5.ps1` - Allow log on locally
- `2.2.16.ps1` - Deny access to this computer from the network
- `2.2.20.ps1` - Deny log on through Remote Desktop Services
- `2.2.19.ps1` - Deny log on locally

**⚠️ IMPACT:**
- **CRITICAL:** May completely block remote access (RDP, file shares, admin tools)
- May prevent non-admin users from logging in locally
- May disable network file sharing access
- Scripts provide manual guidance only - requires Group Policy configuration
- **When applied:** Immediate - affects next login attempt

### 4. Remote Desktop Services (Section 18.10.57.x)
**May disable or restrict RDP access**

**⚠️ IMPACT:**
- May require secure RPC communication (breaking some RDP clients)
- May enforce encryption levels that older clients don't support
- May disconnect idle sessions
- **When applied:** Immediate - may disconnect current RDP sessions

### 5. Administrative Shares (C$, IPC$, Admin$)
**Status:** These are controlled by Security Options (2.3.x) if present

To check if any scripts affect admin shares:
```powershell
Get-ChildItem *.ps1 | Select-String -Pattern "Admin\$|IPC\$|C\$" | Select-Object Filename
```

**⚠️ IMPACT:**
- If disabled: Remote admin tools may not work
- File sharing to C$, Admin$ will be blocked
- Some management software may break
- **When applied:** Immediate

---

## PowerShell Commands for Batch Execution

### ⭐ RECOMMENDED: Option 1 - Run All Scripts with Logging
```powershell
# Navigate to scripts directory
cd "C:\Path\To\RemediationScripts"

# Run all scripts with detailed logging
Get-ChildItem *.ps1 | ForEach-Object {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Executing: $($_.Name)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    try {
        & $_.FullName
        Write-Host "✓ SUCCESS: $($_.Name)" -ForegroundColor Green
        Add-Content -Path "success.log" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SUCCESS: $($_.Name)"
    } catch {
        Write-Host "✗ FAILED: $($_.Name)" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        Add-Content -Path "failed.log" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - FAILED: $($_.Name) - $_"
    }
} *>&1 | Tee-Object -FilePath "remediation-full-log.txt"
```

### ⭐ SAFER: Option 2 - Run by Category
```powershell
# Run only registry-based settings (lower risk)
Get-ChildItem "18.*.ps1" | ForEach-Object { & $_.FullName }

# Run password policies (requires testing first!)
Get-ChildItem "1.1.*.ps1" | ForEach-Object { & $_.FullName }

# Run account lockout policies (requires testing first!)
Get-ChildItem "1.2.*.ps1" | ForEach-Object { & $_.FullName }

# Run firewall settings
Get-ChildItem "9.*.ps1" | ForEach-Object { & $_.FullName }

# Run audit policies (guidance only)
Get-ChildItem "17.*.ps1" | ForEach-Object { & $_.FullName }
```

### Option 3 - Interactive Mode with Confirmation
```powershell
Get-ChildItem *.ps1 | ForEach-Object {
    Write-Host "`nScript: $($_.Name)" -ForegroundColor Yellow
    
    # Show first few lines of description
    Get-Content $_.FullName | Select-Object -First 10 | Write-Host
    
    $response = Read-Host "`nExecute this script? (Y/N/Q to quit)"
    
    if ($response -eq 'Q') { 
        Write-Host "Batch execution cancelled." -ForegroundColor Red
        break 
    }
    
    if ($response -eq 'Y') {
        try {
            & $_.FullName
            Write-Host "✓ Completed successfully" -ForegroundColor Green
        } catch {
            Write-Host "✗ Failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Skipped." -ForegroundColor Gray
    }
}
```

### ⭐ RECOMMENDED FOR FIRST RUN: Option 4 - Skip High-Impact Controls
```powershell
# Skip password policies, lockout policies, and user rights
Get-ChildItem *.ps1 | Where-Object { 
    $_.Name -notmatch "^1\.[12]\." -and  # Skip sections 1.1 and 1.2
    $_.Name -notmatch "^2\.2\."          # Skip section 2.2 (user rights)
} | ForEach-Object { 
    Write-Host "Executing: $($_.Name)" -ForegroundColor Cyan
    & $_.FullName 
}
```

### Option 5 - Run Specific Categories Only
```powershell
# Define categories to run
$categories = @("18", "19")  # Admin templates only

Get-ChildItem *.ps1 | Where-Object {
    $name = $_.Name
    $categories | Where-Object { $name -match "^$_\." }
} | ForEach-Object { & $_.FullName }
```

### Option 6 - Parallel Execution (ADVANCED - Use with caution)
```powershell
# Run multiple scripts in parallel (faster but harder to debug)
Get-ChildItem *.ps1 | ForEach-Object -Parallel {
    & $_.FullName
} -ThrottleLimit 5
```

---

## 🛡️ Pre-Execution Checklist

**BEFORE running ANY batch command:**

### 1. Create System Restore Point
```powershell
Checkpoint-Computer -Description "Before CIS Remediation $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -RestorePointType "MODIFY_SETTINGS"
```

### 2. Backup Current Security Settings
```powershell
# Backup current security policy
secedit /export /cfg ".\security-policy-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').inf"

# Backup registry (key locations)
reg export "HKLM\SOFTWARE\Policies" ".\registry-policies-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg" /y
reg export "HKLM\SYSTEM\CurrentControlSet\Services" ".\services-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg" /y
```

### 3. Document Current State
```powershell
# Export current Group Policy settings
gpresult /h ".\gp-report-before-$(Get-Date -Format 'yyyyMMdd').html"

# Export current firewall settings
netsh advfirewall export ".\firewall-backup-$(Get-Date -Format 'yyyyMMdd').wfw"
```

### 4. Test Access Methods
```powershell
# Verify you can access system locally
Write-Host "Testing local access..." -ForegroundColor Cyan

# Verify RDP works (if needed)
Test-NetConnection -ComputerName localhost -Port 3389

# Verify network shares work (if needed)
Test-Path "\\$env:COMPUTERNAME\C$"
```

---

## 🚨 Critical Warnings

### Do NOT Run If:
- ❌ You don't have local console/physical access to the machine
- ❌ This is a production server without maintenance window
- ❌ You haven't tested in a non-production environment first
- ❌ Users are currently logged in and working
- ❌ You're connected via RDP and running user rights scripts
- ❌ You don't have a backup or rollback plan

### High-Risk Scenarios:
1. **Running remotely via RDP + applying RDP restrictions** = 🔒 Lockout risk
2. **Running user rights (2.2.x) scripts** = 🔒 May lose all remote access
3. **Running password policies on active directory** = 👥 All users affected
4. **Running account lockout without warning users** = 📞 Help desk overload

---

## 🔧 Troubleshooting & Recovery

### If You Get Locked Out

**From RDP:**
1. Connect via local console or VM console
2. Revert settings using backups:
   ```powershell
   secedit /configure /db secedit.sdb /cfg "security-policy-backup-YYYYMMDD-HHMMSS.inf"
   ```

**From Local Console:**
1. Run PowerShell as Administrator
2. Import registry backups:
   ```powershell
   reg import "registry-policies-backup-YYYYMMDD-HHMMSS.reg"
   ```
3. Restart system

**Using System Restore:**
1. Boot to Safe Mode (if needed)
2. Run: `rstrui.exe`
3. Select restore point created before remediation
4. Complete restore and reboot

### If Scripts Fail

**Check logs:**
```powershell
Get-Content "failed.log"
Get-Content "remediation-full-log.txt" | Select-String -Pattern "Error|Failed"
```

**Revert specific setting:**
```powershell
# For registry settings
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\..." -Name "SettingName"

# For security policy - edit and reimport
notepad "security-policy-backup.inf"
secedit /configure /db secedit.sdb /cfg "security-policy-backup.inf"
```

---

## 📋 Recommended Execution Order

### Phase 1: Low-Risk Settings (Test Environment)
```powershell
# Day 1: Administrative Templates (18.x, 19.x)
Get-ChildItem "18.*.ps1", "19.*.ps1" | ForEach-Object { & $_.FullName }
```

### Phase 2: Medium-Risk Settings (Test Environment)
```powershell
# Day 2-3: Firewall and Audit
Get-ChildItem "9.*.ps1", "17.*.ps1" | ForEach-Object { & $_.FullName }
```

### Phase 3: High-Risk Settings (Test Environment, then Production)
```powershell
# Day 4-5: Security Options
Get-ChildItem "2.3.*.ps1" | ForEach-Object { & $_.FullName }

# Day 6: Password Policies (announce to users first!)
Get-ChildItem "1.1.*.ps1" | ForEach-Object { & $_.FullName }

# Day 7: Account Lockout (announce to users and help desk!)
Get-ChildItem "1.2.*.ps1" | ForEach-Object { & $_.FullName }
```

### Phase 4: Manual Configuration Required
- **User Rights (2.2.x):** Configure via Group Policy manually
- **Service permissions (5.x):** Review and configure carefully

---

## 📊 Monitoring After Execution

### Verify Settings Applied
```powershell
# Check security policy
secedit /export /cfg "current-settings.inf"
notepad "current-settings.inf"

# Check registry settings
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\*"

# Check Group Policy results
gpresult /h "gp-report-after.html"
```

### Monitor for Issues
```powershell
# Check for account lockouts
Get-EventLog -LogName Security -InstanceId 4740 -Newest 50

# Check for failed logins
Get-EventLog -LogName Security -InstanceId 4625 -Newest 50

# Check for RDP disconnections
Get-EventLog -LogName System -Source TerminalServices* -Newest 50
```

---

## Summary: Quick Answer to Your Questions

### Q1: Which items may impact access?

**Immediate High Impact:**
- ✅ **Password policies (1.1.x)** - Forces password requirements
- ✅ **Account lockout (1.2.x)** - Locks accounts after 5 failed attempts
- ✅ **User rights (2.2.x)** - May block remote/local access entirely
- ⚠️ **RDP settings (18.10.57.x)** - May break remote desktop
- ⚠️ **Admin shares** - Check 2.3.x scripts for share restrictions

### Q2: What PowerShell command to run all scripts?

**RECOMMENDED (with logging and error handling):**
```powershell
Get-ChildItem *.ps1 | ForEach-Object {
    Write-Host "`n=== $($_.Name) ===" -ForegroundColor Cyan
    try { & $_.FullName; Write-Host "✓ OK" -ForegroundColor Green }
    catch { Write-Host "✗ Failed: $_" -ForegroundColor Red }
} | Tee-Object -FilePath "remediation-log.txt"
```

**SAFER (skip high-risk controls first):**
```powershell
Get-ChildItem *.ps1 | Where-Object { 
    $_.Name -notmatch "^1\.[12]\." -and $_.Name -notmatch "^2\.2\." 
} | ForEach-Object { & $_.FullName }
```

---

## ⚠️ Final Reminder

**Always:**
1. ✅ Test in non-production first
2. ✅ Create restore point before execution
3. ✅ Have local console access
4. ✅ Backup current settings
5. ✅ Run during maintenance window
6. ✅ Notify users of potential disruption

**Never:**
1. ❌ Run on production without testing
2. ❌ Run remotely via RDP (first time)
3. ❌ Run without backups
4. ❌ Run during business hours (first time)

For questions or issues, refer to the main README.md or CIS Benchmark documentation.
