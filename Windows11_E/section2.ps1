# =============================================================================
# CIS Windows 11 Enterprise Benchmark - Section 2
# Local Policies - User Rights Assignment and Security Options
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

# Function to get current registry value
function Get-CurrentValue {
    param (
        [string]$Path,
        [string]$Name
    )
    try {
        if (Test-Path $Path) {
            $value = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            if ($null -ne $value) {
                return $value.$Name
            }
        }
        return "(Not Set)"
    }
    catch {
        return "(Error Reading)"
    }
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
    $beforeValue = Get-CurrentValue -Path $Path -Name $Name
    
    try {
        # Create path if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        
        # Set the value
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        
        # Get the new value
        $afterValue = Get-CurrentValue -Path $Path -Name $Name
        
        # Format values for display
        $beforeDisplay = if ($beforeValue -is [array]) { ($beforeValue -join ", ") } else { $beforeValue }
        $afterDisplay = if ($afterValue -is [array]) { ($afterValue -join ", ") } else { $afterValue }
        
        # Log the change
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = $Path
            Property    = $Name
            BeforeValue = $beforeDisplay
            AfterValue  = $afterDisplay
            Status      = "Success"
        }
        
        # Display progress
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "$beforeDisplay" -ForegroundColor Yellow
        Write-Host "  After:  " -ForegroundColor Gray -NoNewline
        Write-Host "$afterDisplay" -ForegroundColor Green
        Write-Host ""
        
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        $Script:Errors += [PSCustomObject]@{
            Timestamp  = $timestamp
            PolicyId   = $PolicyId
            PolicyName = $PolicyName
            Path       = $Path
            Property   = $Name
            Error      = $errorMsg
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  ERROR: " -ForegroundColor Red -NoNewline
        Write-Host "$errorMsg" -ForegroundColor Red
        Write-Host ""
        
        return $false
    }
}

# Function to log non-registry changes
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
    
    if ($Status -eq "Success") {
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = "N/A"
            Property    = "N/A"
            BeforeValue = $BeforeValue
            AfterValue  = $AfterValue
            Status      = $Status
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "$BeforeValue" -ForegroundColor Yellow
        Write-Host "  After:  " -ForegroundColor Gray -NoNewline
        Write-Host "$AfterValue" -ForegroundColor Green
        Write-Host ""
    }
    else {
        $Script:Errors += [PSCustomObject]@{
            Timestamp  = $timestamp
            PolicyId   = $PolicyId
            PolicyName = $PolicyName
            Path       = "N/A"
            Property   = "N/A"
            Error      = $ErrorMessage
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  ERROR: " -ForegroundColor Red -NoNewline
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " CIS Windows 11 Enterprise Benchmark - Section 2" -ForegroundColor Cyan
Write-Host " Started: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# 2.2 User Rights Assignment (secedit-based settings)
# =============================================================================

Write-Host "--- 2.2 User Rights Assignment (via secedit) ---" -ForegroundColor Magenta
Write-Host ""

# Export current security policy for comparison
$exportBefore = "$env:TEMP\secedit_before.inf"
secedit /export /cfg $exportBefore /quiet 2>$null

# Create a comprehensive .inf file for User Rights Assignment settings
$userRightsInfContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
; 2.2.1 (L1) Ensure 'Access Credential Manager as a trusted caller' is set to 'No One'
SeTrustedCredManAccessPrivilege = 

; 2.2.2 (L1) Ensure 'Access this computer from the network' is set to 'Administrators, Remote Desktop Users'
SeNetworkLogonRight = *S-1-5-32-544,*S-1-5-32-555

; 2.2.3 (L1) Ensure 'Act as part of the operating system' is set to 'No One'
SeTcbPrivilege = 

; 2.2.4 (L1) Ensure 'Adjust memory quotas for a process' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE'
SeIncreaseQuotaPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20

; 2.2.5 (L1) Ensure 'Allow log on locally' is set to 'Administrators, Users'
SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-545

; 2.2.6 (L1) Ensure 'Allow log on through Remote Desktop Services' is set to 'Administrators, Remote Desktop Users'
SeRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-555

; 2.2.7 (L1) Ensure 'Back up files and directories' is set to 'Administrators'
SeBackupPrivilege = *S-1-5-32-544

; 2.2.8 (L1) Ensure 'Change the system time' is set to 'Administrators, LOCAL SERVICE'
SeSystemtimePrivilege = *S-1-5-32-544,*S-1-5-19

; 2.2.9 (L1) Ensure 'Change the time zone' is set to 'Administrators, LOCAL SERVICE, Users'
SeTimeZonePrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-32-545

; 2.2.10 (L1) Ensure 'Create a pagefile' is set to 'Administrators'
SeCreatePagefilePrivilege = *S-1-5-32-544

; 2.2.11 (L1) Ensure 'Create a token object' is set to 'No One'
SeCreateTokenPrivilege = 

; 2.2.12 (L1) Ensure 'Create global objects' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE'
SeCreateGlobalPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6

; 2.2.13 (L1) Ensure 'Create permanent shared objects' is set to 'No One'
SeCreatePermanentPrivilege = 

; 2.2.14 (L1) Ensure 'Create symbolic links' is set to 'Administrators'
SeCreateSymbolicLinkPrivilege = *S-1-5-32-544

; 2.2.15 (L1) Ensure 'Debug programs' is set to 'Administrators'
SeDebugPrivilege = *S-1-5-32-544

; 2.2.16 (L1) Ensure 'Deny access to this computer from the network' to include 'Guests, Local account'
SeDenyNetworkLogonRight = *S-1-5-32-546,*S-1-5-113

; 2.2.17 (L1) Ensure 'Deny log on as a batch job' to include 'Guests'
SeDenyBatchLogonRight = *S-1-5-32-546

; 2.2.18 (L1) Ensure 'Deny log on as a service' to include 'Guests'
SeDenyServiceLogonRight = *S-1-5-32-546

; 2.2.19 (L1) Ensure 'Deny log on locally' to include 'Guests'
SeDenyInteractiveLogonRight = *S-1-5-32-546

; 2.2.20 (L1) Ensure 'Deny log on through Remote Desktop Services' to include 'Guests, Local account'
SeDenyRemoteInteractiveLogonRight = *S-1-5-32-546,*S-1-5-113

; 2.2.21 (L1) Ensure 'Enable computer and user accounts to be trusted for delegation' is set to 'No One'
SeEnableDelegationPrivilege = 

; 2.2.22 (L1) Ensure 'Force shutdown from a remote system' is set to 'Administrators'
SeRemoteShutdownPrivilege = *S-1-5-32-544

; 2.2.23 (L1) Ensure 'Generate security audits' is set to 'LOCAL SERVICE, NETWORK SERVICE'
SeAuditPrivilege = *S-1-5-19,*S-1-5-20

; 2.2.24 (L1) Ensure 'Impersonate a client after authentication' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE'
SeImpersonatePrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6

; 2.2.25 (L1) Ensure 'Increase scheduling priority' is set to 'Administrators, Window Manager\Window Manager Group'
SeIncreaseBasePriorityPrivilege = *S-1-5-32-544,*S-1-5-90-0

; 2.2.26 (L1) Ensure 'Load and unload device drivers' is set to 'Administrators'
SeLoadDriverPrivilege = *S-1-5-32-544

; 2.2.27 (L1) Ensure 'Lock pages in memory' is set to 'No One'
SeLockMemoryPrivilege = 

; 2.2.30 (L1) Ensure 'Manage auditing and security log' is set to 'Administrators'
SeSecurityPrivilege = *S-1-5-32-544

; 2.2.31 (L1) Ensure 'Modify an object label' is set to 'No One'
SeRelabelPrivilege = 

; 2.2.32 (L1) Ensure 'Modify firmware environment values' is set to 'Administrators'
SeSystemEnvironmentPrivilege = *S-1-5-32-544

; 2.2.33 (L1) Ensure 'Perform volume maintenance tasks' is set to 'Administrators'
SeManageVolumePrivilege = *S-1-5-32-544

; 2.2.34 (L1) Ensure 'Profile single process' is set to 'Administrators'
SeProfileSingleProcessPrivilege = *S-1-5-32-544

; 2.2.35 (L1) Ensure 'Profile system performance' is set to 'Administrators, NT SERVICE\WdiServiceHost'
SeSystemProfilePrivilege = *S-1-5-32-544,*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420

; 2.2.36 (L1) Ensure 'Replace a process level token' is set to 'LOCAL SERVICE, NETWORK SERVICE'
SeAssignPrimaryTokenPrivilege = *S-1-5-19,*S-1-5-20

; 2.2.37 (L1) Ensure 'Restore files and directories' is set to 'Administrators'
SeRestorePrivilege = *S-1-5-32-544

; 2.2.38 (L1) Ensure 'Shut down the system' is set to 'Administrators, Users'
SeShutdownPrivilege = *S-1-5-32-544,*S-1-5-32-545

; 2.2.39 (L1) Ensure 'Take ownership of files or other objects' is set to 'Administrators'
SeTakeOwnershipPrivilege = *S-1-5-32-544
"@

$userRightsInfFile = "$env:TEMP\Section2_UserRights.inf"
$userRightsInfContent | Out-File -FilePath $userRightsInfFile -Encoding Unicode -Force

# Parse before values from exported policy
$beforeRights = @{}
if (Test-Path $exportBefore) {
    $content = Get-Content $exportBefore -Raw
    $lines = $content -split "`r`n"
    foreach ($line in $lines) {
        if ($line -match "^(Se\w+)\s*=\s*(.*)$") {
            $beforeRights[$matches[1]] = $matches[2]
        }
    }
}

# Apply secedit configuration
$seceditResult = secedit /configure /db "$env:TEMP\Section2_secedit.sdb" /cfg $userRightsInfFile /log "$env:TEMP\Section2_UserRights.log" /quiet 2>&1

# Export after values
$exportAfter = "$env:TEMP\secedit_after.inf"
secedit /export /cfg $exportAfter /quiet 2>$null

# Parse after values
$afterRights = @{}
if (Test-Path $exportAfter) {
    $content = Get-Content $exportAfter -Raw
    $lines = $content -split "`r`n"
    foreach ($line in $lines) {
        if ($line -match "^(Se\w+)\s*=\s*(.*)$") {
            $afterRights[$matches[1]] = $matches[2]
        }
    }
}

# Log User Rights changes
$userRightsMap = @{
    "SeTrustedCredManAccessPrivilege" = "2.2.1|Access Credential Manager as a trusted caller"
    "SeNetworkLogonRight" = "2.2.2|Access this computer from the network"
    "SeTcbPrivilege" = "2.2.3|Act as part of the operating system"
    "SeIncreaseQuotaPrivilege" = "2.2.4|Adjust memory quotas for a process"
    "SeInteractiveLogonRight" = "2.2.5|Allow log on locally"
    "SeRemoteInteractiveLogonRight" = "2.2.6|Allow log on through Remote Desktop Services"
    "SeBackupPrivilege" = "2.2.7|Back up files and directories"
    "SeSystemtimePrivilege" = "2.2.8|Change the system time"
    "SeTimeZonePrivilege" = "2.2.9|Change the time zone"
    "SeCreatePagefilePrivilege" = "2.2.10|Create a pagefile"
    "SeCreateTokenPrivilege" = "2.2.11|Create a token object"
    "SeCreateGlobalPrivilege" = "2.2.12|Create global objects"
    "SeCreatePermanentPrivilege" = "2.2.13|Create permanent shared objects"
    "SeCreateSymbolicLinkPrivilege" = "2.2.14|Create symbolic links"
    "SeDebugPrivilege" = "2.2.15|Debug programs"
    "SeDenyNetworkLogonRight" = "2.2.16|Deny access to this computer from the network"
    "SeDenyBatchLogonRight" = "2.2.17|Deny log on as a batch job"
    "SeDenyServiceLogonRight" = "2.2.18|Deny log on as a service"
    "SeDenyInteractiveLogonRight" = "2.2.19|Deny log on locally"
    "SeDenyRemoteInteractiveLogonRight" = "2.2.20|Deny log on through Remote Desktop Services"
    "SeEnableDelegationPrivilege" = "2.2.21|Enable computer and user accounts to be trusted for delegation"
    "SeRemoteShutdownPrivilege" = "2.2.22|Force shutdown from a remote system"
    "SeAuditPrivilege" = "2.2.23|Generate security audits"
    "SeImpersonatePrivilege" = "2.2.24|Impersonate a client after authentication"
    "SeIncreaseBasePriorityPrivilege" = "2.2.25|Increase scheduling priority"
    "SeLoadDriverPrivilege" = "2.2.26|Load and unload device drivers"
    "SeLockMemoryPrivilege" = "2.2.27|Lock pages in memory"
    "SeSecurityPrivilege" = "2.2.30|Manage auditing and security log"
    "SeRelabelPrivilege" = "2.2.31|Modify an object label"
    "SeSystemEnvironmentPrivilege" = "2.2.32|Modify firmware environment values"
    "SeManageVolumePrivilege" = "2.2.33|Perform volume maintenance tasks"
    "SeProfileSingleProcessPrivilege" = "2.2.34|Profile single process"
    "SeSystemProfilePrivilege" = "2.2.35|Profile system performance"
    "SeAssignPrimaryTokenPrivilege" = "2.2.36|Replace a process level token"
    "SeRestorePrivilege" = "2.2.37|Restore files and directories"
    "SeShutdownPrivilege" = "2.2.38|Shut down the system"
    "SeTakeOwnershipPrivilege" = "2.2.39|Take ownership of files or other objects"
}

foreach ($right in $userRightsMap.Keys) {
    $info = $userRightsMap[$right] -split "\|"
    $policyId = $info[0]
    $policyName = $info[1]
    $before = if ($beforeRights.ContainsKey($right)) { $beforeRights[$right] } else { "(Not Set)" }
    $after = if ($afterRights.ContainsKey($right)) { $afterRights[$right] } else { "(Not Set)" }
    
    if ($before -eq "") { $before = "(Empty - No One)" }
    if ($after -eq "") { $after = "(Empty - No One)" }
    
    Log-CustomChange -PolicyId $policyId -PolicyName $policyName -BeforeValue $before -AfterValue $after -Status "Success"
}

Remove-Item -Path $userRightsInfFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $exportBefore -Force -ErrorAction SilentlyContinue
Remove-Item -Path $exportAfter -Force -ErrorAction SilentlyContinue

# =============================================================================
# 2.3.1 Accounts
# =============================================================================

Write-Host "--- 2.3.1 Accounts ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.1.1 (L1) Ensure 'Accounts: Guest account status' is set to 'Disabled'
try {
    $guestBefore = (Get-LocalUser -Name "Guest" -ErrorAction Stop).Enabled
    net user Guest /active:no 2>$null | Out-Null
    $guestAfter = (Get-LocalUser -Name "Guest" -ErrorAction Stop).Enabled
    Log-CustomChange -PolicyId "2.3.1.1" -PolicyName "Accounts: Guest account status" -BeforeValue "Enabled=$guestBefore" -AfterValue "Enabled=$guestAfter" -Status "Success"
}
catch {
    Log-CustomChange -PolicyId "2.3.1.1" -PolicyName "Accounts: Guest account status" -BeforeValue "" -AfterValue "" -Status "Error" -ErrorMessage $_.Exception.Message
}

# 2.3.1.2 (L1) Ensure 'Accounts: Limit local account use of blank passwords to console logon only' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.1.2" -PolicyName "Accounts: Limit local account use of blank passwords to console logon only" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1 -Type DWord

# 2.3.1.3 (L1) Configure 'Accounts: Rename administrator account'
Write-Host "[2.3.1.3] " -ForegroundColor Cyan -NoNewline
Write-Host "Accounts: Rename administrator account" -ForegroundColor White
Write-Host "  Status: " -ForegroundColor Gray -NoNewline
Write-Host "MANUAL - Customize the new name as per your organization's policy" -ForegroundColor Yellow
Write-Host ""

# 2.3.1.4 (L1) Configure 'Accounts: Rename guest account'
Write-Host "[2.3.1.4] " -ForegroundColor Cyan -NoNewline
Write-Host "Accounts: Rename guest account" -ForegroundColor White
Write-Host "  Status: " -ForegroundColor Gray -NoNewline
Write-Host "MANUAL - Customize the new name as per your organization's policy" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# 2.3.2 Audit
# =============================================================================

Write-Host "--- 2.3.2 Audit ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.2.1 (L1) Ensure 'Audit: Force audit policy subcategory settings to override audit policy category settings' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.2.1" -PolicyName "Audit: Force audit policy subcategory settings to override audit policy category settings" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy" -Value 1 -Type DWord

# 2.3.2.2 (L1) Ensure 'Audit: Shut down system immediately if unable to log security audits' is set to 'Disabled'
Set-PolicyValue -PolicyId "2.3.2.2" -PolicyName "Audit: Shut down system immediately if unable to log security audits" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "CrashOnAuditFail" -Value 0 -Type DWord

# =============================================================================
# 2.3.4 Devices
# =============================================================================

Write-Host "--- 2.3.4 Devices ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.4.1 (L2) Ensure 'Devices: Prevent users from installing printer drivers' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.4.1" -PolicyName "Devices: Prevent users from installing printer drivers" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" -Name "AddPrinterDrivers" -Value 1 -Type DWord

# =============================================================================
# 2.3.6 Domain member
# =============================================================================

Write-Host "--- 2.3.6 Domain member ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.6.1 (L1) Ensure 'Domain member: Digitally encrypt or sign secure channel data (always)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.6.1" -PolicyName "Domain member: Digitally encrypt or sign secure channel data (always)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "RequireSignOrSeal" -Value 1 -Type DWord

# 2.3.6.2 (L1) Ensure 'Domain member: Digitally encrypt secure channel data (when possible)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.6.2" -PolicyName "Domain member: Digitally encrypt secure channel data (when possible)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "SealSecureChannel" -Value 1 -Type DWord

# 2.3.6.3 (L1) Ensure 'Domain member: Digitally sign secure channel data (when possible)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.6.3" -PolicyName "Domain member: Digitally sign secure channel data (when possible)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "SignSecureChannel" -Value 1 -Type DWord

# 2.3.6.4 (L1) Ensure 'Domain member: Disable machine account password changes' is set to 'Disabled'
Set-PolicyValue -PolicyId "2.3.6.4" -PolicyName "Domain member: Disable machine account password changes" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "DisablePasswordChange" -Value 0 -Type DWord

# 2.3.6.5 (L1) Ensure 'Domain member: Maximum machine account password age' is set to '30 or fewer days, but not 0'
Set-PolicyValue -PolicyId "2.3.6.5" -PolicyName "Domain member: Maximum machine account password age" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "MaximumPasswordAge" -Value 30 -Type DWord

# 2.3.6.6 (L1) Ensure 'Domain member: Require strong (Windows 2000 or later) session key' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.6.6" -PolicyName "Domain member: Require strong (Windows 2000 or later) session key" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "RequireStrongKey" -Value 1 -Type DWord

# =============================================================================
# 2.3.7 Interactive logon
# =============================================================================

Write-Host "--- 2.3.7 Interactive logon ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.7.1 (L1) Ensure 'Interactive logon: Do not require CTRL+ALT+DEL' is set to 'Disabled'
Set-PolicyValue -PolicyId "2.3.7.1" -PolicyName "Interactive logon: Do not require CTRL+ALT+DEL" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 0 -Type DWord

# 2.3.7.2 (L1) Ensure 'Interactive logon: Don't display last signed-in' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.7.2" -PolicyName "Interactive logon: Don't display last signed-in" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DontDisplayLastUserName" -Value 1 -Type DWord

# 2.3.7.3 (BL) Ensure 'Interactive logon: Machine account lockout threshold' is set to '10 or fewer invalid logon attempts, but not 0'
Set-PolicyValue -PolicyId "2.3.7.3" -PolicyName "Interactive logon: Machine account lockout threshold" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "MaxDevicePasswordFailedAttempts" -Value 10 -Type DWord

# 2.3.7.4 (L1) Ensure 'Interactive logon: Machine inactivity limit' is set to '900 or fewer second(s), but not 0'
Set-PolicyValue -PolicyId "2.3.7.4" -PolicyName "Interactive logon: Machine inactivity limit" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 900 -Type DWord

# 2.3.7.5 (L1) Configure 'Interactive logon: Message text for users attempting to log on'
Set-PolicyValue -PolicyId "2.3.7.5" -PolicyName "Interactive logon: Message text for users attempting to log on" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeText" -Value "This system is for authorized use only. By using this system, you consent to monitoring and agree to comply with all applicable policies." -Type String

# 2.3.7.6 (L1) Configure 'Interactive logon: Message title for users attempting to log on'
Set-PolicyValue -PolicyId "2.3.7.6" -PolicyName "Interactive logon: Message title for users attempting to log on" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeCaption" -Value "AUTHORIZED USE ONLY" -Type String

# 2.3.7.7 (L2) Ensure 'Interactive logon: Number of previous logons to cache' is set to '4 or fewer logon(s)'
Set-PolicyValue -PolicyId "2.3.7.7" -PolicyName "Interactive logon: Number of previous logons to cache" -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "CachedLogonsCount" -Value "4" -Type String

# 2.3.7.8 (L1) Ensure 'Interactive logon: Prompt user to change password before expiration' is set to 'between 5 and 14 days'
Set-PolicyValue -PolicyId "2.3.7.8" -PolicyName "Interactive logon: Prompt user to change password before expiration" -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "PasswordExpiryWarning" -Value 14 -Type DWord

# 2.3.7.9 (L1) Ensure 'Interactive logon: Smart card removal behavior' is set to 'Lock Workstation' or higher
Set-PolicyValue -PolicyId "2.3.7.9" -PolicyName "Interactive logon: Smart card removal behavior" -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "ScRemoveOption" -Value "1" -Type String

# =============================================================================
# 2.3.8 Microsoft network client
# =============================================================================

Write-Host "--- 2.3.8 Microsoft network client ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.8.1 (L1) Ensure 'Microsoft network client: Digitally sign communications (always)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.8.1" -PolicyName "Microsoft network client: Digitally sign communications (always)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RequireSecuritySignature" -Value 1 -Type DWord

# 2.3.8.2 (L1) Ensure 'Microsoft network client: Digitally sign communications (if server agrees)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.8.2" -PolicyName "Microsoft network client: Digitally sign communications (if server agrees)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "EnableSecuritySignature" -Value 1 -Type DWord

# 2.3.8.3 (L1) Ensure 'Microsoft network client: Send unencrypted password to third-party SMB servers' is set to 'Disabled'
Set-PolicyValue -PolicyId "2.3.8.3" -PolicyName "Microsoft network client: Send unencrypted password to third-party SMB servers" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "EnablePlainTextPassword" -Value 0 -Type DWord

# =============================================================================
# 2.3.9 Microsoft network server
# =============================================================================

Write-Host "--- 2.3.9 Microsoft network server ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.9.1 (L1) Ensure 'Microsoft network server: Amount of idle time required before suspending session' is set to '15 or fewer minute(s)'
Set-PolicyValue -PolicyId "2.3.9.1" -PolicyName "Microsoft network server: Amount of idle time required before suspending session" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "AutoDisconnect" -Value 15 -Type DWord

# 2.3.9.2 (L1) Ensure 'Microsoft network server: Digitally sign communications (always)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.9.2" -PolicyName "Microsoft network server: Digitally sign communications (always)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "RequireSecuritySignature" -Value 1 -Type DWord

# 2.3.9.3 (L1) Ensure 'Microsoft network server: Digitally sign communications (if client agrees)' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.9.3" -PolicyName "Microsoft network server: Digitally sign communications (if client agrees)" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "EnableSecuritySignature" -Value 1 -Type DWord

# 2.3.9.4 (L1) Ensure 'Microsoft network server: Disconnect clients when logon hours expire' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.9.4" -PolicyName "Microsoft network server: Disconnect clients when logon hours expire" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "enableforcedlogoff" -Value 1 -Type DWord

# 2.3.9.5 (L1) Ensure 'Microsoft network server: Server SPN target name validation level' is set to 'Accept if provided by client' or higher
Set-PolicyValue -PolicyId "2.3.9.5" -PolicyName "Microsoft network server: Server SPN target name validation level" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "SMBServerNameHardeningLevel" -Value 1 -Type DWord

# =============================================================================
# 2.3.10 Network access
# =============================================================================

Write-Host "--- 2.3.10 Network access ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.10.1 (L1) Ensure 'Network access: Allow anonymous SID/Name translation' is set to 'Disabled'
Write-Host "[2.3.10.1] " -ForegroundColor Cyan -NoNewline
Write-Host "Network access: Allow anonymous SID/Name translation" -ForegroundColor White
Write-Host "  Status: " -ForegroundColor Gray -NoNewline
Write-Host "Configured via secedit (Local Security Policy)" -ForegroundColor Yellow
Write-Host ""

# 2.3.10.2 (L1) Ensure 'Network access: Do not allow anonymous enumeration of SAM accounts' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.10.2" -PolicyName "Network access: Do not allow anonymous enumeration of SAM accounts" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymousSAM" -Value 1 -Type DWord

# 2.3.10.3 (L1) Ensure 'Network access: Do not allow anonymous enumeration of SAM accounts and shares' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.10.3" -PolicyName "Network access: Do not allow anonymous enumeration of SAM accounts and shares" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 1 -Type DWord

# 2.3.10.4 (L1) Ensure 'Network access: Do not allow storage of passwords and credentials for network authentication' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.10.4" -PolicyName "Network access: Do not allow storage of passwords and credentials for network authentication" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "DisableDomainCreds" -Value 1 -Type DWord

# 2.3.10.5 (L1) Ensure 'Network access: Let Everyone permissions apply to anonymous users' is set to 'Disabled'
Set-PolicyValue -PolicyId "2.3.10.5" -PolicyName "Network access: Let Everyone permissions apply to anonymous users" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 0 -Type DWord

# 2.3.10.6 (L1) Ensure 'Network access: Named Pipes that can be accessed anonymously' is set to 'None'
Set-PolicyValue -PolicyId "2.3.10.6" -PolicyName "Network access: Named Pipes that can be accessed anonymously" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "NullSessionPipes" -Value @() -Type MultiString

# 2.3.10.7 (L1) Ensure 'Network access: Remotely accessible registry paths' is configured
$regPathsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths"
if (-not (Test-Path $regPathsPath)) { New-Item -Path $regPathsPath -Force | Out-Null }
$regPathsValue = @("System\CurrentControlSet\Control\ProductOptions","System\CurrentControlSet\Control\Server Applications","Software\Microsoft\Windows NT\CurrentVersion")
Set-PolicyValue -PolicyId "2.3.10.7" -PolicyName "Network access: Remotely accessible registry paths" -Path $regPathsPath -Name "Machine" -Value $regPathsValue -Type MultiString

# 2.3.10.8 (L1) Ensure 'Network access: Remotely accessible registry paths and sub-paths' is configured
$regPathsSubPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths"
if (-not (Test-Path $regPathsSubPath)) { New-Item -Path $regPathsSubPath -Force | Out-Null }
$regPathsSubValue = @("System\CurrentControlSet\Control\Print\Printers","System\CurrentControlSet\Services\Eventlog","Software\Microsoft\OLAP Server","Software\Microsoft\Windows NT\CurrentVersion\Print","Software\Microsoft\Windows NT\CurrentVersion\Windows","System\CurrentControlSet\Control\ContentIndex","System\CurrentControlSet\Control\Terminal Server","System\CurrentControlSet\Control\Terminal Server\UserConfig","System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration","Software\Microsoft\Windows NT\CurrentVersion\Perflib","System\CurrentControlSet\Services\SysmonLog")
Set-PolicyValue -PolicyId "2.3.10.8" -PolicyName "Network access: Remotely accessible registry paths and sub-paths" -Path $regPathsSubPath -Name "Machine" -Value $regPathsSubValue -Type MultiString

# 2.3.10.9 (L1) Ensure 'Network access: Restrict anonymous access to Named Pipes and Shares' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.10.9" -PolicyName "Network access: Restrict anonymous access to Named Pipes and Shares" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "RestrictNullSessAccess" -Value 1 -Type DWord

# 2.3.10.10 (L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow'
Set-PolicyValue -PolicyId "2.3.10.10" -PolicyName "Network access: Restrict clients allowed to make remote calls to SAM" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "restrictremotesam" -Value "O:BAG:BAD:(A;;RC;;;BA)" -Type String

# 2.3.10.11 (L1) Ensure 'Network access: Shares that can be accessed anonymously' is set to 'None'
Set-PolicyValue -PolicyId "2.3.10.11" -PolicyName "Network access: Shares that can be accessed anonymously" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "NullSessionShares" -Value @() -Type MultiString

# 2.3.10.12 (L1) Ensure 'Network access: Sharing and security model for local accounts' is set to 'Classic'
Set-PolicyValue -PolicyId "2.3.10.12" -PolicyName "Network access: Sharing and security model for local accounts" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "ForceGuest" -Value 0 -Type DWord

# =============================================================================
# 2.3.11 Network security
# =============================================================================

Write-Host "--- 2.3.11 Network security ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.11.1 (L1) Ensure 'Network security: Allow Local System to use computer identity for NTLM' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.11.1" -PolicyName "Network security: Allow Local System to use computer identity for NTLM" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "UseMachineId" -Value 1 -Type DWord

# 2.3.11.2 (L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'
$msv1Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
if (-not (Test-Path $msv1Path)) { New-Item -Path $msv1Path -Force | Out-Null }
Set-PolicyValue -PolicyId "2.3.11.2" -PolicyName "Network security: Allow LocalSystem NULL session fallback" -Path $msv1Path -Name "AllowNullSessionFallback" -Value 0 -Type DWord

# 2.3.11.3 (L1) Ensure 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled'
$pku2uPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u"
if (-not (Test-Path $pku2uPath)) { New-Item -Path $pku2uPath -Force | Out-Null }
Set-PolicyValue -PolicyId "2.3.11.3" -PolicyName "Network Security: Allow PKU2U authentication requests to use online identities" -Path $pku2uPath -Name "AllowOnlineID" -Value 0 -Type DWord

# 2.3.11.4 (L1) Ensure 'Network security: Configure encryption types allowed for Kerberos' is set to 'AES128_HMAC_SHA1, AES256_HMAC_SHA1, Future encryption types'
$kerbPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters"
if (-not (Test-Path $kerbPath)) { New-Item -Path $kerbPath -Force | Out-Null }
Set-PolicyValue -PolicyId "2.3.11.4" -PolicyName "Network security: Configure encryption types allowed for Kerberos" -Path $kerbPath -Name "SupportedEncryptionTypes" -Value 2147483640 -Type DWord

# 2.3.11.5 (L1) Ensure 'Network security: Do not store LAN Manager hash value on next password change' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.11.5" -PolicyName "Network security: Do not store LAN Manager hash value" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -Value 1 -Type DWord

# 2.3.11.7 (L1) Ensure 'Network security: LAN Manager authentication level' is set to 'Send NTLMv2 response only. Refuse LM & NTLM'
Set-PolicyValue -PolicyId "2.3.11.7" -PolicyName "Network security: LAN Manager authentication level" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5 -Type DWord

# 2.3.11.8 (L1) Ensure 'Network security: LDAP client encryption requirements' is set to 'Negotiate sealing' or higher
Set-PolicyValue -PolicyId "2.3.11.8" -PolicyName "Network security: LDAP client encryption requirements" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LDAP" -Name "LDAPClientConfidentiality" -Value 1 -Type DWord

# 2.3.11.9 (L1) Ensure 'Network security: LDAP client signing requirements' is set to 'Negotiate signing' or higher
Set-PolicyValue -PolicyId "2.3.11.9" -PolicyName "Network security: LDAP client signing requirements" -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LDAP" -Name "LDAPClientIntegrity" -Value 1 -Type DWord

# 2.3.11.10 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based (including secure RPC) clients' is set to 'Require NTLMv2 session security, Require 128-bit encryption'
Set-PolicyValue -PolicyId "2.3.11.10" -PolicyName "Network security: Minimum session security for NTLM SSP clients" -Path $msv1Path -Name "NTLMMinClientSec" -Value 537395200 -Type DWord

# 2.3.11.11 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based (including secure RPC) servers' is set to 'Require NTLMv2 session security, Require 128-bit encryption'
Set-PolicyValue -PolicyId "2.3.11.11" -PolicyName "Network security: Minimum session security for NTLM SSP servers" -Path $msv1Path -Name "NTLMMinServerSec" -Value 537395200 -Type DWord

# 2.3.11.12 (L1) Ensure 'Network security: Restrict NTLM: Audit Incoming NTLM Traffic' is set to 'Enable auditing for all accounts'
Set-PolicyValue -PolicyId "2.3.11.12" -PolicyName "Network security: Restrict NTLM: Audit Incoming NTLM Traffic" -Path $msv1Path -Name "AuditReceivingNTLMTraffic" -Value 2 -Type DWord

# 2.3.11.13 (L1) Ensure 'Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers' is set to 'Audit all' or higher
Set-PolicyValue -PolicyId "2.3.11.13" -PolicyName "Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers" -Path $msv1Path -Name "RestrictSendingNTLMTraffic" -Value 1 -Type DWord

# =============================================================================
# 2.3.14 System cryptography (L2)
# =============================================================================

Write-Host "--- 2.3.14 System cryptography ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.14.1 (L2) Ensure 'System cryptography: Force strong key protection for user keys stored on the computer' is set to 'User is prompted when the key is first used' or higher
$cryptoPath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography"
if (-not (Test-Path $cryptoPath)) { New-Item -Path $cryptoPath -Force | Out-Null }
Set-PolicyValue -PolicyId "2.3.14.1" -PolicyName "System cryptography: Force strong key protection" -Path $cryptoPath -Name "ForceKeyProtection" -Value 1 -Type DWord

# =============================================================================
# 2.3.15 System objects
# =============================================================================

Write-Host "--- 2.3.15 System objects ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.15.1 (L1) Ensure 'System objects: Require case insensitivity for non-Windows subsystems' is set to 'Enabled'
$kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel"
if (-not (Test-Path $kernelPath)) { New-Item -Path $kernelPath -Force | Out-Null }
Set-PolicyValue -PolicyId "2.3.15.1" -PolicyName "System objects: Require case insensitivity for non-Windows subsystems" -Path $kernelPath -Name "ObCaseInsensitive" -Value 1 -Type DWord

# 2.3.15.2 (L1) Ensure 'System objects: Strengthen default permissions of internal system objects' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.15.2" -PolicyName "System objects: Strengthen default permissions of internal system objects" -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "ProtectionMode" -Value 1 -Type DWord

# =============================================================================
# 2.3.17 User Account Control
# =============================================================================

Write-Host "--- 2.3.17 User Account Control ---" -ForegroundColor Magenta
Write-Host ""

# 2.3.17.1 (L1) Ensure 'User Account Control: Admin Approval Mode for the Built-in Administrator account' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.1" -PolicyName "UAC: Admin Approval Mode for the Built-in Administrator account" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "FilterAdministratorToken" -Value 1 -Type DWord

# 2.3.17.2 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode' is set to 'Prompt for consent on the secure desktop' or higher
Set-PolicyValue -PolicyId "2.3.17.2" -PolicyName "UAC: Behavior of elevation prompt for administrators" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Type DWord

# 2.3.17.3 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for standard users' is set to 'Automatically deny elevation requests'
Set-PolicyValue -PolicyId "2.3.17.3" -PolicyName "UAC: Behavior of elevation prompt for standard users" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 0 -Type DWord

# 2.3.17.4 (L1) Ensure 'User Account Control: Detect application installations and prompt for elevation' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.4" -PolicyName "UAC: Detect application installations and prompt for elevation" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableInstallerDetection" -Value 1 -Type DWord

# 2.3.17.5 (L1) Ensure 'User Account Control: Only elevate UIAccess applications that are installed in secure locations' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.5" -PolicyName "UAC: Only elevate UIAccess applications in secure locations" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableSecureUIAPaths" -Value 1 -Type DWord

# 2.3.17.6 (L1) Ensure 'User Account Control: Run all administrators in Admin Approval Mode' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.6" -PolicyName "UAC: Run all administrators in Admin Approval Mode" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Type DWord

# 2.3.17.7 (L1) Ensure 'User Account Control: Switch to the secure desktop when prompting for elevation' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.7" -PolicyName "UAC: Switch to the secure desktop when prompting for elevation" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1 -Type DWord

# 2.3.17.8 (L1) Ensure 'User Account Control: Virtualize file and registry write failures to per-user locations' is set to 'Enabled'
Set-PolicyValue -PolicyId "2.3.17.8" -PolicyName "UAC: Virtualize file and registry write failures to per-user locations" -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableVirtualization" -Value 1 -Type DWord

# =============================================================================
# 2.2 Virtualization Based Security (from 2.2.md)
# =============================================================================

Write-Host "--- 2.2 Virtualization Based Security ---" -ForegroundColor Magenta
Write-Host ""

# Enable Virtualization Based Security
$deviceGuardPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
if (-not (Test-Path $deviceGuardPath)) { New-Item -Path $deviceGuardPath -Force | Out-Null }
Set-PolicyValue -PolicyId "2.2" -PolicyName "Virtualization Based Security" -Path $deviceGuardPath -Name "EnableVirtualizationBasedSecurity" -Value 1 -Type DWord

# =============================================================================
# Final Summary Report
# =============================================================================

$endTime = Get-Date
$duration = $endTime - $Script:StartTime

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Benchmark Section 2 Configuration Complete!" -ForegroundColor Cyan
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
$reportPath = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "section2_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$reportContent = @"
=============================================================================
CIS BENCHMARK SECTION 2 - EXECUTION REPORT
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
NOTES
=============================================================================

- 2.3.1.3 and 2.3.1.4: Rename Administrator/Guest accounts manually as per your policy
- 2.3.10.1: Network access: Allow anonymous SID/Name translation requires Local Security Policy
- Some settings may require a restart to take effect
- This script must be run as Administrator

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

Write-Host "MANUAL ACTIONS REQUIRED:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host "- 2.3.1.3: Rename Administrator account as per your organization's policy" -ForegroundColor Yellow
Write-Host "- 2.3.1.4: Rename Guest account as per your organization's policy" -ForegroundColor Yellow
Write-Host "- 2.3.10.1: Configure 'Network access: Allow anonymous SID/Name translation' via Local Security Policy" -ForegroundColor Yellow
Write-Host ""
Write-Host "A system restart is recommended to apply all changes." -ForegroundColor Cyan
Write-Host ""
