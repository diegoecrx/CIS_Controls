#Requires -RunAsAdministrator
<#
.SYNOPSIS
    CIS Windows 11 Enterprise Benchmark - Section 9: Windows Defender Firewall with Advanced Security
    
.DESCRIPTION
    This script implements CIS Benchmark Section 9 recommendations for Windows Defender Firewall
    with Advanced Security. It configures firewall settings for Domain, Private, and Public profiles.
    
    All settings are Level 1 (L1) - Corporate/Enterprise Environment recommendations.
    
.NOTES
    Version:        1.0
    Author:         CIS Benchmark Implementation
    Benchmark:      CIS Microsoft Windows 11 Enterprise v3.0.0
    Section:        9 - Windows Defender Firewall with Advanced Security
    
.EXAMPLE
    .\section9.ps1
    Runs the script and applies all Section 9 CIS benchmark configurations.
#>

# Script-level variables for tracking changes
$Script:Changes = @()
$Script:Errors = @()
$Script:StartTime = Get-Date

# Log file setup
$LogPath = "$PSScriptRoot\CIS_Section9_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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

function Set-FirewallRegistryValue {
    param(
        [string]$CISControl,
        [string]$Description,
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord'
    )
    
    try {
        # Create registry path if it doesn't exist
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Log "Created registry path: $Path" -Level INFO
        }
        
        # Get current value
        $CurrentValue = $null
        try {
            $CurrentValue = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue
        } catch {
            $CurrentValue = "(Not Set)"
        }
        
        # Set the new value based on type
        if ($Type -eq 'String') {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type String -Force
        } else {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord -Force
        }
        
        # Verify the change
        $NewValue = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue
        
        $Script:Changes += [PSCustomObject]@{
            CISControl  = $CISControl
            Description = $Description
            Path        = $Path
            Setting     = $Name
            OldValue    = $CurrentValue
            NewValue    = $NewValue
            Status      = 'Applied'
        }
        
        Write-Log "[$CISControl] $Description - Changed from '$CurrentValue' to '$NewValue'" -Level SUCCESS
        return $true
    }
    catch {
        $Script:Errors += [PSCustomObject]@{
            CISControl  = $CISControl
            Description = $Description
            Path        = $Path
            Setting     = $Name
            Error       = $_.Exception.Message
        }
        
        Write-Log "[$CISControl] Failed to apply $Description - $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================================
# Section 9.1 - Domain Profile
# ============================================================================

Write-Log "=" * 80 -Level INFO
Write-Log "CIS Windows 11 Enterprise - Section 9: Windows Defender Firewall" -Level INFO
Write-Log "Starting configuration at $(Get-Date)" -Level INFO
Write-Log "=" * 80 -Level INFO

Write-Log "--- Section 9.1: Domain Profile ---" -Level INFO

# 9.1.1 (L1) Ensure 'Windows Firewall: Domain: Firewall state' is set to 'On (recommended)'
Set-FirewallRegistryValue `
    -CISControl "9.1.1" `
    -Description "Windows Firewall: Domain: Firewall state - On" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" `
    -Name "EnableFirewall" `
    -Value 1

# 9.1.2 (L1) Ensure 'Windows Firewall: Domain: Inbound connections' is set to 'Block (default)'
Set-FirewallRegistryValue `
    -CISControl "9.1.2" `
    -Description "Windows Firewall: Domain: Inbound connections - Block" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" `
    -Name "DefaultInboundAction" `
    -Value 1

# 9.1.3 (L1) Ensure 'Windows Firewall: Domain: Settings: Display a notification' is set to 'No'
Set-FirewallRegistryValue `
    -CISControl "9.1.3" `
    -Description "Windows Firewall: Domain: Display notifications - No" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" `
    -Name "DisableNotifications" `
    -Value 1

# 9.1.4 (L1) Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\domainfw.log'
Set-FirewallRegistryValue `
    -CISControl "9.1.4" `
    -Description "Windows Firewall: Domain: Log file path" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" `
    -Name "LogFilePath" `
    -Value "%SystemRoot%\System32\logfiles\firewall\domainfw.log" `
    -Type "String"

# 9.1.5 (L1) Ensure 'Windows Firewall: Domain: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-FirewallRegistryValue `
    -CISControl "9.1.5" `
    -Description "Windows Firewall: Domain: Log size limit - 16384 KB" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" `
    -Name "LogFileSize" `
    -Value 16384

# 9.1.6 (L1) Ensure 'Windows Firewall: Domain: Logging: Log dropped packets' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.1.6" `
    -Description "Windows Firewall: Domain: Log dropped packets - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" `
    -Name "LogDroppedPackets" `
    -Value 1

# 9.1.7 (L1) Ensure 'Windows Firewall: Domain: Logging: Log successful connections' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.1.7" `
    -Description "Windows Firewall: Domain: Log successful connections - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" `
    -Name "LogSuccessfulConnections" `
    -Value 1

# ============================================================================
# Section 9.2 - Private Profile
# ============================================================================

Write-Log "--- Section 9.2: Private Profile ---" -Level INFO

# 9.2.1 (L1) Ensure 'Windows Firewall: Private: Firewall state' is set to 'On (recommended)'
Set-FirewallRegistryValue `
    -CISControl "9.2.1" `
    -Description "Windows Firewall: Private: Firewall state - On" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" `
    -Name "EnableFirewall" `
    -Value 1

# 9.2.2 (L1) Ensure 'Windows Firewall: Private: Inbound connections' is set to 'Block (default)'
Set-FirewallRegistryValue `
    -CISControl "9.2.2" `
    -Description "Windows Firewall: Private: Inbound connections - Block" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" `
    -Name "DefaultInboundAction" `
    -Value 1

# 9.2.3 (L1) Ensure 'Windows Firewall: Private: Settings: Display a notification' is set to 'No'
Set-FirewallRegistryValue `
    -CISControl "9.2.3" `
    -Description "Windows Firewall: Private: Display notifications - No" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" `
    -Name "DisableNotifications" `
    -Value 1

# 9.2.4 (L1) Ensure 'Windows Firewall: Private: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\privatefw.log'
Set-FirewallRegistryValue `
    -CISControl "9.2.4" `
    -Description "Windows Firewall: Private: Log file path" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" `
    -Name "LogFilePath" `
    -Value "%SystemRoot%\System32\logfiles\firewall\privatefw.log" `
    -Type "String"

# 9.2.5 (L1) Ensure 'Windows Firewall: Private: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-FirewallRegistryValue `
    -CISControl "9.2.5" `
    -Description "Windows Firewall: Private: Log size limit - 16384 KB" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" `
    -Name "LogFileSize" `
    -Value 16384

# 9.2.6 (L1) Ensure 'Windows Firewall: Private: Logging: Log dropped packets' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.2.6" `
    -Description "Windows Firewall: Private: Log dropped packets - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" `
    -Name "LogDroppedPackets" `
    -Value 1

# 9.2.7 (L1) Ensure 'Windows Firewall: Private: Logging: Log successful connections' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.2.7" `
    -Description "Windows Firewall: Private: Log successful connections - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" `
    -Name "LogSuccessfulConnections" `
    -Value 1

# ============================================================================
# Section 9.3 - Public Profile
# ============================================================================

Write-Log "--- Section 9.3: Public Profile ---" -Level INFO

# 9.3.1 (L1) Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (recommended)'
Set-FirewallRegistryValue `
    -CISControl "9.3.1" `
    -Description "Windows Firewall: Public: Firewall state - On" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -Name "EnableFirewall" `
    -Value 1

# 9.3.2 (L1) Ensure 'Windows Firewall: Public: Inbound connections' is set to 'Block (default)'
Set-FirewallRegistryValue `
    -CISControl "9.3.2" `
    -Description "Windows Firewall: Public: Inbound connections - Block" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -Name "DefaultInboundAction" `
    -Value 1

# 9.3.3 (L1) Ensure 'Windows Firewall: Public: Settings: Display a notification' is set to 'No'
Set-FirewallRegistryValue `
    -CISControl "9.3.3" `
    -Description "Windows Firewall: Public: Display notifications - No" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -Name "DisableNotifications" `
    -Value 1

# 9.3.4 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local firewall rules' is set to 'No'
Set-FirewallRegistryValue `
    -CISControl "9.3.4" `
    -Description "Windows Firewall: Public: Apply local firewall rules - No" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -Name "AllowLocalPolicyMerge" `
    -Value 0

# 9.3.5 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local connection security rules' is set to 'No'
Set-FirewallRegistryValue `
    -CISControl "9.3.5" `
    -Description "Windows Firewall: Public: Apply local connection security rules - No" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -Name "AllowLocalIPsecPolicyMerge" `
    -Value 0

# 9.3.6 (L1) Ensure 'Windows Firewall: Public: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\publicfw.log'
Set-FirewallRegistryValue `
    -CISControl "9.3.6" `
    -Description "Windows Firewall: Public: Log file path" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" `
    -Name "LogFilePath" `
    -Value "%SystemRoot%\System32\logfiles\firewall\publicfw.log" `
    -Type "String"

# 9.3.7 (L1) Ensure 'Windows Firewall: Public: Logging: Size limit (KB)' is set to '16,384 KB or greater'
Set-FirewallRegistryValue `
    -CISControl "9.3.7" `
    -Description "Windows Firewall: Public: Log size limit - 16384 KB" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" `
    -Name "LogFileSize" `
    -Value 16384

# 9.3.8 (L1) Ensure 'Windows Firewall: Public: Logging: Log dropped packets' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.3.8" `
    -Description "Windows Firewall: Public: Log dropped packets - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" `
    -Name "LogDroppedPackets" `
    -Value 1

# 9.3.9 (L1) Ensure 'Windows Firewall: Public: Logging: Log successful connections' is set to 'Yes'
Set-FirewallRegistryValue `
    -CISControl "9.3.9" `
    -Description "Windows Firewall: Public: Log successful connections - Yes" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" `
    -Name "LogSuccessfulConnections" `
    -Value 1

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

Write-Log "Total settings configured: $TotalChanges" -Level INFO
Write-Log "Total errors encountered: $TotalErrors" -Level $(if ($TotalErrors -gt 0) { 'WARNING' } else { 'SUCCESS' })

# Detailed changes report
if ($Script:Changes.Count -gt 0) {
    Write-Log "" -Level INFO
    Write-Log "DETAILED CHANGES:" -Level INFO
    Write-Log "-" * 80 -Level INFO
    
    foreach ($Change in $Script:Changes) {
        Write-Log "[$($Change.CISControl)] $($Change.Description)" -Level INFO
        Write-Log "    Path: $($Change.Path)" -Level INFO
        Write-Log "    Setting: $($Change.Setting)" -Level INFO
        Write-Log "    Before: $($Change.OldValue)" -Level INFO
        Write-Log "    After: $($Change.NewValue)" -Level INFO
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
        Write-Log "    Path: $($Error.Path)" -Level ERROR
        Write-Log "    Setting: $($Error.Setting)" -Level ERROR
        Write-Log "    Error: $($Error.Error)" -Level ERROR
        Write-Log "" -Level INFO
    }
}

# Export reports to CSV
$ReportPath = "$PSScriptRoot\CIS_Section9_Changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$Script:Changes | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Log "Changes exported to: $ReportPath" -Level INFO

if ($Script:Errors.Count -gt 0) {
    $ErrorReportPath = "$PSScriptRoot\CIS_Section9_Errors_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Script:Errors | Export-Csv -Path $ErrorReportPath -NoTypeInformation
    Write-Log "Errors exported to: $ErrorReportPath" -Level WARNING
}

Write-Log "" -Level INFO
Write-Log "CIS Windows 11 Enterprise Section 9 - Windows Defender Firewall configuration complete." -Level SUCCESS
Write-Log "Log file: $LogPath" -Level INFO

# Summary by profile
Write-Log "" -Level INFO
Write-Log "PROFILE SUMMARY:" -Level INFO
Write-Log "-" * 40 -Level INFO

$DomainSettings = ($Script:Changes | Where-Object { $_.CISControl -like "9.1.*" }).Count
$PrivateSettings = ($Script:Changes | Where-Object { $_.CISControl -like "9.2.*" }).Count
$PublicSettings = ($Script:Changes | Where-Object { $_.CISControl -like "9.3.*" }).Count

Write-Log "Domain Profile:  $DomainSettings settings configured" -Level INFO
Write-Log "Private Profile: $PrivateSettings settings configured" -Level INFO
Write-Log "Public Profile:  $PublicSettings settings configured" -Level INFO
Write-Log "" -Level INFO

# Return summary object
[PSCustomObject]@{
    TotalChanges    = $TotalChanges
    TotalErrors     = $TotalErrors
    Duration        = $Duration.TotalSeconds
    LogFile         = $LogPath
    ReportFile      = $ReportPath
    DomainSettings  = $DomainSettings
    PrivateSettings = $PrivateSettings
    PublicSettings  = $PublicSettings
}
