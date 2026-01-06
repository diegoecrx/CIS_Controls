#Requires -RunAsAdministrator
<#
.SYNOPSIS
    CIS Windows 11 Enterprise Benchmark - Section 19: Administrative Templates (User)
    
.DESCRIPTION
    This script implements CIS Benchmark Section 19 recommendations for User Configuration
    Administrative Templates. These are per-user settings applied via registry under HKU.
    
    Settings covered:
    - 19.5: Start Menu and Taskbar (Notifications)
    - 19.6: System (Internet Communication Settings)
    - 19.7: Windows Components (Attachment Manager, Cloud Content, Network Sharing, 
            Windows Copilot, Windows Installer, Windows Media Player)
    
    L1 = Level 1 (Corporate/Enterprise) - 10 settings
    L2 = Level 2 (High Security) - 3 settings
    
.NOTES
    Version:        1.0
    Author:         CIS Benchmark Implementation
    Benchmark:      CIS Microsoft Windows 11 Enterprise v3.0.0
    Section:        19 - Administrative Templates (User)
    
.EXAMPLE
    .\section19.ps1
    Runs the script and applies all Section 19 CIS benchmark configurations.
#>

# Script-level variables for tracking changes
$Script:Changes = @()
$Script:Errors = @()
$Script:StartTime = Get-Date

# Log file setup
$LogPath = "$PSScriptRoot\CIS_Section19_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        'ERROR'   { Write-Host $LogMessage -ForegroundColor Red }
        'WARNING' { Write-Host $LogMessage -ForegroundColor Yellow }
        'SUCCESS' { Write-Host $LogMessage -ForegroundColor Green }
        default   { Write-Host $LogMessage -ForegroundColor White }
    }
    
    Add-Content -Path $LogPath -Value $LogMessage
}

function Set-UserRegistryValue {
    param(
        [string]$CISControl,
        [string]$Description,
        [string]$SubPath,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord',
        [string]$Level = 'L1'
    )
    
    try {
        # Get all user SIDs from the registry
        $UserSIDs = Get-ChildItem "Registry::HKEY_USERS" | 
                    Where-Object { $_.PSChildName -match '^S-1-5-21-\d+-\d+-\d+-\d+$' } |
                    Select-Object -ExpandProperty PSChildName
        
        # Also apply to default user profile for new users
        $DefaultUserPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies"
        
        $AppliedCount = 0
        $UserResults = @()
        
        foreach ($SID in $UserSIDs) {
            $FullPath = "Registry::HKEY_USERS\$SID\$SubPath"
            
            try {
                # Create registry path if it doesn't exist
                if (!(Test-Path $FullPath)) {
                    New-Item -Path $FullPath -Force | Out-Null
                }
                
                # Get current value
                $CurrentValue = $null
                try {
                    $CurrentValue = Get-ItemPropertyValue -Path $FullPath -Name $Name -ErrorAction SilentlyContinue
                } catch {
                    $CurrentValue = "(Not Set)"
                }
                
                # Set the new value based on type
                if ($Type -eq 'String') {
                    Set-ItemProperty -Path $FullPath -Name $Name -Value $Value -Type String -Force
                } else {
                    Set-ItemProperty -Path $FullPath -Name $Name -Value $Value -Type DWord -Force
                }
                
                # Verify the change
                $NewValue = Get-ItemPropertyValue -Path $FullPath -Name $Name -ErrorAction SilentlyContinue
                
                $UserResults += [PSCustomObject]@{
                    SID      = $SID
                    OldValue = $CurrentValue
                    NewValue = $NewValue
                    Status   = 'Applied'
                }
                
                $AppliedCount++
            }
            catch {
                $UserResults += [PSCustomObject]@{
                    SID      = $SID
                    OldValue = $null
                    NewValue = $null
                    Status   = "Failed: $($_.Exception.Message)"
                }
            }
        }
        
        # If no user profiles found, apply to current user via HKCU
        if ($UserSIDs.Count -eq 0) {
            $FullPath = "HKCU:\$SubPath"
            
            if (!(Test-Path $FullPath)) {
                New-Item -Path $FullPath -Force | Out-Null
            }
            
            $CurrentValue = $null
            try {
                $CurrentValue = Get-ItemPropertyValue -Path $FullPath -Name $Name -ErrorAction SilentlyContinue
            } catch {
                $CurrentValue = "(Not Set)"
            }
            
            if ($Type -eq 'String') {
                Set-ItemProperty -Path $FullPath -Name $Name -Value $Value -Type String -Force
            } else {
                Set-ItemProperty -Path $FullPath -Name $Name -Value $Value -Type DWord -Force
            }
            
            $NewValue = Get-ItemPropertyValue -Path $FullPath -Name $Name -ErrorAction SilentlyContinue
            
            $UserResults += [PSCustomObject]@{
                SID      = "HKCU"
                OldValue = $CurrentValue
                NewValue = $NewValue
                Status   = 'Applied'
            }
            
            $AppliedCount = 1
        }
        
        $Script:Changes += [PSCustomObject]@{
            CISControl   = $CISControl
            Description  = $Description
            Level        = $Level
            SubPath      = $SubPath
            Setting      = $Name
            TargetValue  = $Value
            UsersApplied = $AppliedCount
            Details      = $UserResults
            Status       = 'Applied'
        }
        
        Write-Log "[$CISControl] [$Level] $Description - Applied to $AppliedCount user(s)" -Level SUCCESS
        return $true
    }
    catch {
        $Script:Errors += [PSCustomObject]@{
            CISControl  = $CISControl
            Description = $Description
            Level       = $Level
            SubPath     = $SubPath
            Setting     = $Name
            Error       = $_.Exception.Message
        }
        
        Write-Log "[$CISControl] Failed to apply $Description - $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================================
# Section 19 - Administrative Templates (User)
# ============================================================================

Write-Log "=" * 80 -Level INFO
Write-Log "CIS Windows 11 Enterprise - Section 19: Administrative Templates (User)" -Level INFO
Write-Log "Starting configuration at $(Get-Date)" -Level INFO
Write-Log "=" * 80 -Level INFO

# ============================================================================
# Section 19.5 - Start Menu and Taskbar
# ============================================================================

Write-Log "--- Section 19.5: Start Menu and Taskbar ---" -Level INFO

# 19.5.1.1 (L1) Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.5.1.1" `
    -Description "Turn off toast notifications on the lock screen - Enabled" `
    -SubPath "Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" `
    -Name "NoToastApplicationNotificationOnLockScreen" `
    -Value 1 `
    -Level "L1"

# ============================================================================
# Section 19.6 - System
# ============================================================================

Write-Log "--- Section 19.6: System (Internet Communication Settings) ---" -Level INFO

# 19.6.6.1.1 (L2) Ensure 'Turn off Help Experience Improvement Program' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.6.6.1.1" `
    -Description "Turn off Help Experience Improvement Program - Enabled" `
    -SubPath "Software\Policies\Microsoft\Assistance\Client\1.0" `
    -Name "NoImplicitFeedback" `
    -Value 1 `
    -Level "L2"

# ============================================================================
# Section 19.7 - Windows Components
# ============================================================================

Write-Log "--- Section 19.7: Windows Components ---" -Level INFO

# ============================================================================
# Section 19.7.5 - Attachment Manager
# ============================================================================

Write-Log "    --- 19.7.5: Attachment Manager ---" -Level INFO

# 19.7.5.1 (L1) Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled'
# Note: Value of 2 means Disabled (preserve zone information)
Set-UserRegistryValue `
    -CISControl "19.7.5.1" `
    -Description "Do not preserve zone information in file attachments - Disabled" `
    -SubPath "Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" `
    -Name "SaveZoneInformation" `
    -Value 2 `
    -Level "L1"

# 19.7.5.2 (L1) Ensure 'Notify antivirus programs when opening attachments' is set to 'Enabled'
# Value of 3 means Enabled
Set-UserRegistryValue `
    -CISControl "19.7.5.2" `
    -Description "Notify antivirus programs when opening attachments - Enabled" `
    -SubPath "Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" `
    -Name "ScanWithAntiVirus" `
    -Value 3 `
    -Level "L1"

# ============================================================================
# Section 19.7.8 - Cloud Content
# ============================================================================

Write-Log "    --- 19.7.8: Cloud Content ---" -Level INFO

# 19.7.8.1 (L1) Ensure 'Configure Windows spotlight on lock screen' is set to 'Disabled'
# Value of 2 means Disabled
Set-UserRegistryValue `
    -CISControl "19.7.8.1" `
    -Description "Configure Windows spotlight on lock screen - Disabled" `
    -SubPath "Software\Policies\Microsoft\Windows\CloudContent" `
    -Name "ConfigureWindowsSpotlight" `
    -Value 2 `
    -Level "L1"

# 19.7.8.2 (L1) Ensure 'Do not suggest third-party content in Windows spotlight' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.8.2" `
    -Description "Do not suggest third-party content in Windows spotlight - Enabled" `
    -SubPath "Software\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableThirdPartySuggestions" `
    -Value 1 `
    -Level "L1"

# 19.7.8.3 (L2) Ensure 'Do not use diagnostic data for tailored experiences' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.8.3" `
    -Description "Do not use diagnostic data for tailored experiences - Enabled" `
    -SubPath "Software\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableTailoredExperiencesWithDiagnosticData" `
    -Value 1 `
    -Level "L2"

# 19.7.8.4 (L2) Ensure 'Turn off all Windows spotlight features' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.8.4" `
    -Description "Turn off all Windows spotlight features - Enabled" `
    -SubPath "Software\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableWindowsSpotlightFeatures" `
    -Value 1 `
    -Level "L2"

# 19.7.8.5 (L1) Ensure 'Turn off Spotlight collection on Desktop' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.8.5" `
    -Description "Turn off Spotlight collection on Desktop - Enabled" `
    -SubPath "SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableSpotlightCollectionOnDesktop" `
    -Value 1 `
    -Level "L1"

# ============================================================================
# Section 19.7.26 - Network Sharing
# ============================================================================

Write-Log "    --- 19.7.26: Network Sharing ---" -Level INFO

# 19.7.26.1 (L1) Ensure 'Prevent users from sharing files within their profile' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.26.1" `
    -Description "Prevent users from sharing files within their profile - Enabled" `
    -SubPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoInplaceSharing" `
    -Value 1 `
    -Level "L1"

# ============================================================================
# Section 19.7.40 - Windows Copilot
# ============================================================================

Write-Log "    --- 19.7.40: Windows Copilot ---" -Level INFO

# 19.7.40.1 (L1) Ensure 'Turn off Windows Copilot' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.40.1" `
    -Description "Turn off Windows Copilot - Enabled" `
    -SubPath "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
    -Name "TurnOffWindowsCopilot" `
    -Value 1 `
    -Level "L1"

# ============================================================================
# Section 19.7.44 - Windows Installer
# ============================================================================

Write-Log "    --- 19.7.44: Windows Installer ---" -Level INFO

# 19.7.44.1 (L1) Ensure 'Always install with elevated privileges' is set to 'Disabled'
# Value of 0 means Disabled
Set-UserRegistryValue `
    -CISControl "19.7.44.1" `
    -Description "Always install with elevated privileges - Disabled" `
    -SubPath "Software\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" `
    -Value 0 `
    -Level "L1"

# ============================================================================
# Section 19.7.46 - Windows Media Player
# ============================================================================

Write-Log "    --- 19.7.46: Windows Media Player ---" -Level INFO

# 19.7.46.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'
Set-UserRegistryValue `
    -CISControl "19.7.46.2.1" `
    -Description "Prevent Codec Download - Enabled" `
    -SubPath "Software\Policies\Microsoft\WindowsMediaPlayer" `
    -Name "PreventCodecDownload" `
    -Value 1 `
    -Level "L2"

# ============================================================================
# Summary Report
# ============================================================================

Write-Log "=" * 80 -Level INFO
Write-Log "CONFIGURATION SUMMARY" -Level INFO
Write-Log "=" * 80 -Level INFO

$EndTime = Get-Date
$Duration = $EndTime - $Script:StartTime

Write-Log "Completed at: $EndTime" -Level INFO
Write-Log "Duration: $($Duration.TotalSeconds) seconds" -Level INFO
Write-Log "" -Level INFO

# Summary statistics
$TotalChanges = $Script:Changes.Count
$TotalErrors = $Script:Errors.Count

$L1Settings = ($Script:Changes | Where-Object { $_.Level -eq 'L1' }).Count
$L2Settings = ($Script:Changes | Where-Object { $_.Level -eq 'L2' }).Count

Write-Log "Total settings configured: $TotalChanges" -Level INFO
Write-Log "  Level 1 (L1) settings: $L1Settings" -Level INFO
Write-Log "  Level 2 (L2) settings: $L2Settings" -Level INFO
Write-Log "Total errors encountered: $TotalErrors" -Level $(if ($TotalErrors -gt 0) { 'WARNING' } else { 'SUCCESS' })

# Summary by category
Write-Log "" -Level INFO
Write-Log "CATEGORY SUMMARY:" -Level INFO
Write-Log "-" * 40 -Level INFO

$Categories = @{
    "19.5"    = "Start Menu and Taskbar"
    "19.6"    = "System"
    "19.7.5"  = "Attachment Manager"
    "19.7.8"  = "Cloud Content"
    "19.7.26" = "Network Sharing"
    "19.7.40" = "Windows Copilot"
    "19.7.44" = "Windows Installer"
    "19.7.46" = "Windows Media Player"
}

foreach ($Cat in $Categories.GetEnumerator() | Sort-Object Name) {
    $Count = ($Script:Changes | Where-Object { $_.CISControl -like "$($Cat.Name)*" }).Count
    if ($Count -gt 0) {
        Write-Log "$($Cat.Value): $Count setting(s) configured" -Level INFO
    }
}

# Detailed changes report
if ($Script:Changes.Count -gt 0) {
    Write-Log "" -Level INFO
    Write-Log "DETAILED CHANGES:" -Level INFO
    Write-Log "-" * 80 -Level INFO
    
    foreach ($Change in $Script:Changes) {
        Write-Log "[$($Change.CISControl)] [$($Change.Level)] $($Change.Description)" -Level INFO
        Write-Log "    Registry Path: HKU\[SID]\$($Change.SubPath)" -Level INFO
        Write-Log "    Value Name: $($Change.Setting)" -Level INFO
        Write-Log "    Target Value: $($Change.TargetValue)" -Level INFO
        Write-Log "    Users Applied: $($Change.UsersApplied)" -Level INFO
        Write-Log "" -Level INFO
    }
}

# Error report
if ($Script:Errors.Count -gt 0) {
    Write-Log "" -Level INFO
    Write-Log "ERRORS ENCOUNTERED:" -Level ERROR
    Write-Log "-" * 80 -Level INFO
    
    foreach ($Error in $Script:Errors) {
        Write-Log "[$($Error.CISControl)] $($Error.Description)" -Level ERROR
        Write-Log "    Path: $($Error.SubPath)" -Level ERROR
        Write-Log "    Setting: $($Error.Setting)" -Level ERROR
        Write-Log "    Error: $($Error.Error)" -Level ERROR
        Write-Log "" -Level INFO
    }
}

# Export reports to CSV
$ReportPath = "$PSScriptRoot\CIS_Section19_Changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$Script:Changes | Select-Object CISControl, Description, Level, SubPath, Setting, TargetValue, UsersApplied, Status | 
    Export-Csv -Path $ReportPath -NoTypeInformation
Write-Log "Changes exported to: $ReportPath" -Level INFO

if ($Script:Errors.Count -gt 0) {
    $ErrorReportPath = "$PSScriptRoot\CIS_Section19_Errors_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Script:Errors | Export-Csv -Path $ErrorReportPath -NoTypeInformation
    Write-Log "Errors exported to: $ErrorReportPath" -Level WARNING
}

Write-Log "" -Level INFO
Write-Log "CIS Windows 11 Enterprise Section 19 - Administrative Templates (User) configuration complete." -Level SUCCESS
Write-Log "Log file: $LogPath" -Level INFO
Write-Log "" -Level INFO
Write-Log "NOTE: User Configuration policies are applied per-user. New users will need" -Level WARNING
Write-Log "      these settings applied when they log in, or use Group Policy for persistence." -Level WARNING

# Return summary object
[PSCustomObject]@{
    TotalChanges          = $TotalChanges
    TotalErrors           = $TotalErrors
    L1Settings            = $L1Settings
    L2Settings            = $L2Settings
    Duration              = $Duration.TotalSeconds
    LogFile               = $LogPath
    ReportFile            = $ReportPath
    StartMenuTaskbar      = ($Script:Changes | Where-Object { $_.CISControl -like "19.5*" }).Count
    System                = ($Script:Changes | Where-Object { $_.CISControl -like "19.6*" }).Count
    AttachmentManager     = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.5*" }).Count
    CloudContent          = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.8*" }).Count
    NetworkSharing        = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.26*" }).Count
    WindowsCopilot        = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.40*" }).Count
    WindowsInstaller      = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.44*" }).Count
    WindowsMediaPlayer    = ($Script:Changes | Where-Object { $_.CISControl -like "19.7.46*" }).Count
}
