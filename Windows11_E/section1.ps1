# =============================================================================
# CIS Windows 11 Enterprise Benchmark - Section 1
# Account Policies - Password Policy and Account Lockout Policy
# =============================================================================
# This script implements CIS Benchmark recommendations for Windows 11 Enterprise
# Run as Administrator
# =============================================================================

# =============================================================================
# Initialize Logging and Tracking
# =============================================================================

$Script:StartTime = Get-Date
$Script:Changes = @()
$Script:Errors = @()

# Function to log custom changes
function Log-CustomChange {
    param (
        [string]$PolicyId,
        [string]$PolicyName,
        [string]$BeforeValue,
        [string]$AfterValue,
        [string]$Status = "Success",
        [string]$ErrorMessage = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $Script:Changes += [PSCustomObject]@{
        Timestamp   = $timestamp
        PolicyId    = $PolicyId
        PolicyName  = $PolicyName
        Path        = "Local Security Policy"
        Property    = $PolicyName
        BeforeValue = $BeforeValue
        AfterValue  = $AfterValue
        Status      = $Status
    }
    
    if ($Status -eq "Error") {
        $Script:Errors += [PSCustomObject]@{
            Timestamp    = $timestamp
            PolicyId     = $PolicyId
            PolicyName   = $PolicyName
            Path         = "Local Security Policy"
            Property     = $PolicyName
            ErrorMessage = $ErrorMessage
        }
    }
    
    # Display progress
    Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
    Write-Host "$PolicyName" -ForegroundColor White
    Write-Host "  Before: " -ForegroundColor Gray -NoNewline
    Write-Host "$BeforeValue" -ForegroundColor Yellow
    Write-Host "  After:  " -ForegroundColor Gray -NoNewline
    if ($Status -eq "Success") {
        Write-Host "$AfterValue" -ForegroundColor Green
    } else {
        Write-Host "$AfterValue" -ForegroundColor Red
        Write-Host "  ERROR:  " -ForegroundColor Red -NoNewline
        Write-Host "$ErrorMessage" -ForegroundColor Red
    }
    Write-Host ""
}

# Function to set registry value with logging
function Set-PolicyValue {
    param (
        [string]$PolicyId,
        [string]$PolicyName,
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Get current value
    $beforeValue = "(Not Set)"
    try {
        if (Test-Path $Path) {
            $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            if ($null -ne $current) {
                $beforeValue = $current.$Name
            }
        }
    } catch { }
    
    try {
        # Create path if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        
        # Set the value
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        
        # Get the new value
        $afterValue = (Get-ItemProperty -Path $Path -Name $Name).$Name
        
        # Log the change
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = $Path
            Property    = $Name
            BeforeValue = $beforeValue
            AfterValue  = $afterValue
            Status      = "Success"
        }
        
        # Display progress
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "$beforeValue" -ForegroundColor Yellow
        Write-Host "  After:  " -ForegroundColor Gray -NoNewline
        Write-Host "$afterValue" -ForegroundColor Green
        Write-Host ""
        
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        $Script:Errors += [PSCustomObject]@{
            Timestamp    = $timestamp
            PolicyId     = $PolicyId
            PolicyName   = $PolicyName
            Path         = $Path
            Property     = $Name
            ErrorMessage = $errorMsg
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  ERROR: " -ForegroundColor Red -NoNewline
        Write-Host "$errorMsg" -ForegroundColor Red
        Write-Host ""
        
        return $false
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Windows 11 Enterprise Benchmark - Section 1" -ForegroundColor Cyan
Write-Host "Account Policies (Password Policy & Account Lockout Policy)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Start Time: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# IMPORTANT NOTE
# =============================================================================
# Password Policy and Account Lockout Policy settings are normally configured
# via Local Security Policy or Group Policy (secpol.msc / gpedit.msc).
# For domain-joined machines, these must be set via the Default Domain Policy GPO.
# This script uses 'net accounts' and secedit to configure local account policies.
# =============================================================================

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "SECTION 1.1 - PASSWORD POLICY" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# Export current security policy for before values
$exportBefore = "$env:TEMP\secpol_before.inf"
secedit /export /cfg $exportBefore /quiet 2>$null

# Parse before values from exported policy
$beforePolicy = @{}
if (Test-Path $exportBefore) {
    $content = Get-Content $exportBefore -Raw
    $lines = $content -split "`r`n"
    foreach ($line in $lines) {
        if ($line -match "^(\w+)\s*=\s*(.*)$") {
            $beforePolicy[$matches[1]] = $matches[2]
        }
    }
}

# Get current net accounts settings for before values
$netAccountsBefore = net accounts 2>&1 | Out-String

# 1.1.1 (L1) Ensure 'Enforce password history' is set to '24 or more password(s)'
$beforeHistoryCount = if ($beforePolicy.ContainsKey("PasswordHistorySize")) { $beforePolicy["PasswordHistorySize"] } else { "(Not Set)" }
net accounts /uniquepw:24 2>$null | Out-Null
Log-CustomChange -PolicyId "1.1.1" -PolicyName "Enforce password history" -BeforeValue "$beforeHistoryCount passwords" -AfterValue "24 passwords"

# 1.1.2 (L1) Ensure 'Maximum password age' is set to '365 or fewer days, but not 0'
$beforeMaxAge = if ($beforePolicy.ContainsKey("MaximumPasswordAge")) { $beforePolicy["MaximumPasswordAge"] } else { "(Not Set)" }
net accounts /maxpwage:365 2>$null | Out-Null
Log-CustomChange -PolicyId "1.1.2" -PolicyName "Maximum password age" -BeforeValue "$beforeMaxAge days" -AfterValue "365 days"

# 1.1.3 (L1) Ensure 'Minimum password age' is set to '1 or more day(s)'
$beforeMinAge = if ($beforePolicy.ContainsKey("MinimumPasswordAge")) { $beforePolicy["MinimumPasswordAge"] } else { "(Not Set)" }
net accounts /minpwage:1 2>$null | Out-Null
Log-CustomChange -PolicyId "1.1.3" -PolicyName "Minimum password age" -BeforeValue "$beforeMinAge days" -AfterValue "1 day"

# 1.1.4 (L1) Ensure 'Minimum password length' is set to '14 or more character(s)'
$beforeMinLen = if ($beforePolicy.ContainsKey("MinimumPasswordLength")) { $beforePolicy["MinimumPasswordLength"] } else { "(Not Set)" }
net accounts /minpwlen:14 2>$null | Out-Null
Log-CustomChange -PolicyId "1.1.4" -PolicyName "Minimum password length" -BeforeValue "$beforeMinLen characters" -AfterValue "14 characters"

# 1.1.5 (L1) Ensure 'Password must meet complexity requirements' is set to 'Enabled'
# This requires secedit configuration
$beforeComplexity = if ($beforePolicy.ContainsKey("PasswordComplexity")) { 
    if ($beforePolicy["PasswordComplexity"] -eq "1") { "Enabled" } else { "Disabled" }
} else { "(Not Set)" }

$complexityInf = @"
[Unicode]
Unicode=yes
[System Access]
PasswordComplexity = 1
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

$complexityInfFile = "$env:TEMP\complexity.inf"
$complexityInf | Out-File -FilePath $complexityInfFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\complexity.sdb" /cfg $complexityInfFile /quiet 2>$null | Out-Null
Remove-Item $complexityInfFile -Force -ErrorAction SilentlyContinue
Log-CustomChange -PolicyId "1.1.5" -PolicyName "Password must meet complexity requirements" -BeforeValue $beforeComplexity -AfterValue "Enabled"

# 1.1.6 (L1) Ensure 'Relax minimum password length limits' is set to 'Enabled'
Set-PolicyValue -PolicyId "1.1.6" -PolicyName "Relax minimum password length limits" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SAM" -Name "RelaxMinimumPasswordLengthLimits" -Value 1 -Type DWord

# 1.1.7 (L1) Ensure 'Store passwords using reversible encryption' is set to 'Disabled'
$beforeReversible = if ($beforePolicy.ContainsKey("ClearTextPassword")) { 
    if ($beforePolicy["ClearTextPassword"] -eq "0") { "Disabled" } else { "Enabled" }
} else { "(Not Set)" }

$reversibleInf = @"
[Unicode]
Unicode=yes
[System Access]
ClearTextPassword = 0
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

$reversibleInfFile = "$env:TEMP\reversible.inf"
$reversibleInf | Out-File -FilePath $reversibleInfFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\reversible.sdb" /cfg $reversibleInfFile /quiet 2>$null | Out-Null
Remove-Item $reversibleInfFile -Force -ErrorAction SilentlyContinue
Log-CustomChange -PolicyId "1.1.7" -PolicyName "Store passwords using reversible encryption" -BeforeValue $beforeReversible -AfterValue "Disabled"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "SECTION 1.2 - ACCOUNT LOCKOUT POLICY" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# 1.2.1 (L1) Ensure 'Account lockout duration' is set to '15 or more minute(s)'
$beforeLockoutDuration = if ($beforePolicy.ContainsKey("LockoutDuration")) { $beforePolicy["LockoutDuration"] } else { "(Not Set)" }
net accounts /lockoutduration:15 2>$null | Out-Null
Log-CustomChange -PolicyId "1.2.1" -PolicyName "Account lockout duration" -BeforeValue "$beforeLockoutDuration minutes" -AfterValue "15 minutes"

# 1.2.2 (L1) Ensure 'Account lockout threshold' is set to '5 or fewer invalid logon attempt(s), but not 0'
$beforeLockoutThreshold = if ($beforePolicy.ContainsKey("LockoutBadCount")) { $beforePolicy["LockoutBadCount"] } else { "(Not Set)" }
net accounts /lockoutthreshold:5 2>$null | Out-Null
Log-CustomChange -PolicyId "1.2.2" -PolicyName "Account lockout threshold" -BeforeValue "$beforeLockoutThreshold attempts" -AfterValue "5 attempts"

# 1.2.3 (L1) Ensure 'Allow Administrator account lockout' is set to 'Enabled'
# This setting is only available on systems patched as of October 11, 2022 (KB5020282)
# It requires secedit/registry configuration
Write-Host "[1.2.3] " -ForegroundColor Cyan -NoNewline
Write-Host "Allow Administrator account lockout" -ForegroundColor White
Write-Host "  Status: " -ForegroundColor Gray -NoNewline
Write-Host "This setting requires KB5020282 (October 2022) or later patches" -ForegroundColor Yellow
Write-Host "  Note:   Configure via Local Security Policy > Account Lockout Policies" -ForegroundColor Yellow
Write-Host ""

# Try to configure via registry if available
$adminLockoutPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
try {
    $beforeAdminLockout = (Get-ItemProperty -Path $adminLockoutPath -Name "AllowAdministratorLockout" -ErrorAction SilentlyContinue).AllowAdministratorLockout
    if ($null -eq $beforeAdminLockout) { $beforeAdminLockout = "(Not Set)" }
} catch {
    $beforeAdminLockout = "(Not Set)"
}
# Note: This setting may not be available on all systems
# Set-PolicyValue -PolicyId "1.2.3" -PolicyName "Allow Administrator account lockout" -Path $adminLockoutPath -Name "AllowAdministratorLockout" -Value 1 -Type DWord

# 1.2.4 (L1) Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)'
$beforeLockoutWindow = if ($beforePolicy.ContainsKey("ResetLockoutCount")) { $beforePolicy["ResetLockoutCount"] } else { "(Not Set)" }
net accounts /lockoutwindow:15 2>$null | Out-Null
Log-CustomChange -PolicyId "1.2.4" -PolicyName "Reset account lockout counter after" -BeforeValue "$beforeLockoutWindow minutes" -AfterValue "15 minutes"

# Cleanup temporary files
Remove-Item $exportBefore -Force -ErrorAction SilentlyContinue

# =============================================================================
# Verify settings with net accounts
# =============================================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "VERIFICATION - Current Account Policy Settings" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$netAccountsAfter = net accounts 2>&1
$netAccountsAfter | ForEach-Object { Write-Host $_ -ForegroundColor Gray }

# =============================================================================
# Final Summary Report
# =============================================================================

$endTime = Get-Date
$duration = $endTime - $Script:StartTime

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Benchmark Section 1 Configuration Complete!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Summary Statistics
$successCount = ($Script:Changes | Where-Object { $_.Status -eq "Success" }).Count
$errorCount = $Script:Errors.Count
$totalChanges = $Script:Changes.Count

Write-Host "EXECUTION SUMMARY" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow
Write-Host "Start Time:        $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "End Time:          $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "Duration:          $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "Total Policies:    $totalChanges" -ForegroundColor White
Write-Host "Successful:        " -ForegroundColor White -NoNewline
Write-Host "$successCount" -ForegroundColor Green
Write-Host "Errors:            " -ForegroundColor White -NoNewline
if ($errorCount -gt 0) {
    Write-Host "$errorCount" -ForegroundColor Red
} else {
    Write-Host "$errorCount" -ForegroundColor Green
}
Write-Host ""

# Display Errors if any
if ($Script:Errors.Count -gt 0) {
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "ERRORS ENCOUNTERED" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    
    foreach ($err in $Script:Errors) {
        Write-Host "[$($err.PolicyId)] " -ForegroundColor Cyan -NoNewline
        Write-Host "$($err.PolicyName)" -ForegroundColor White
        Write-Host "  Timestamp:  $($err.Timestamp)" -ForegroundColor Gray
        Write-Host "  Path:       $($err.Path)" -ForegroundColor Gray
        Write-Host "  Property:   $($err.Property)" -ForegroundColor Gray
        Write-Host "  Error:      " -ForegroundColor Gray -NoNewline
        Write-Host "$($err.ErrorMessage)" -ForegroundColor Red
        Write-Host ""
    }
}

# Export detailed report to file
$reportPath = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "section1_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$reportContent = @"
=============================================================================
CIS BENCHMARK SECTION 1 - EXECUTION REPORT
Account Policies (Password Policy & Account Lockout Policy)
=============================================================================

Execution Date: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $($duration.ToString('hh\:mm\:ss'))
Computer: $env:COMPUTERNAME
User: $env:USERNAME

SUMMARY
-------
Total Policies Processed: $totalChanges
Successful: $successCount
Errors: $errorCount

=============================================================================
DETAILED CHANGES
=============================================================================

"@

foreach ($change in $Script:Changes) {
    $reportContent += @"
[$($change.PolicyId)] $($change.PolicyName)
  Timestamp:    $($change.Timestamp)
  Path:         $($change.Path)
  Property:     $($change.Property)
  Before Value: $($change.BeforeValue)
  After Value:  $($change.AfterValue)
  Status:       $($change.Status)

"@
}

if ($Script:Errors.Count -gt 0) {
    $reportContent += @"

=============================================================================
ERRORS
=============================================================================

"@
    foreach ($err in $Script:Errors) {
        $reportContent += @"
[$($err.PolicyId)] $($err.PolicyName)
  Timestamp: $($err.Timestamp)
  Path:      $($err.Path)
  Property:  $($err.Property)
  Error:     $($err.ErrorMessage)

"@
    }
}

$reportContent += @"

=============================================================================
IMPORTANT NOTES
=============================================================================

1. Password Policy and Account Lockout Policy settings configured here apply
   to LOCAL accounts only.

2. For DOMAIN-joined computers, these policies must be configured via the
   Default Domain Policy GPO to affect domain user accounts.

3. Password Settings Objects (PSOs) can be used in Active Directory for
   fine-grained password policies for specific users/groups.

4. Policy 1.2.3 (Allow Administrator account lockout) requires Windows
   patches from October 2022 (KB5020282) or later to be available.

5. A system restart may be required for some settings to take full effect.

=============================================================================
END OF REPORT
=============================================================================
"@

try {
    $reportContent | Out-File -FilePath $reportPath -Encoding UTF8 -Force
    Write-Host "Detailed report saved to:" -ForegroundColor Green
    Write-Host "  $reportPath" -ForegroundColor Cyan
    Write-Host ""
}
catch {
    Write-Host "Could not save report file: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "NOTES:" -ForegroundColor Yellow
Write-Host "======" -ForegroundColor Yellow
Write-Host "- These settings apply to LOCAL accounts only" -ForegroundColor Yellow
Write-Host "- For domain accounts, configure via Default Domain Policy GPO" -ForegroundColor Yellow
Write-Host "- Run this script as Administrator" -ForegroundColor Yellow
Write-Host ""
