# =============================================================================
# CIS Windows 11 Enterprise Benchmark - Section 8
# =============================================================================
# This script is a placeholder for Section 8 configurations.
# Run as Administrator
# =============================================================================

# =============================================================================
# IMPORTANT NOTE
# =============================================================================
# The Section 8 markdown files provided appear to be incomplete or contain
# only partial/fragmented content. The available file (8.0.md) contains
# only a fragment about WinRM service configuration which is already
# covered in Section 5 (System Services).
#
# Section 8 in the full CIS Benchmark typically covers:
# - Windows Firewall with Advanced Security
#   - Domain Profile
#   - Private Profile  
#   - Public Profile
#
# If you have the complete Section 8 markdown files, please provide them
# and this script can be updated accordingly.
# =============================================================================

$Script:StartTime = Get-Date
$Script:Changes = @()
$Script:Errors = @()

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
Write-Host "CIS Windows 11 Enterprise Benchmark - Section 8" -ForegroundColor Cyan
Write-Host "Windows Firewall Configuration (Reference Implementation)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Start Time: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTE: The Section 8 source files appear incomplete." -ForegroundColor Yellow
Write-Host "This script implements standard Windows Firewall recommendations" -ForegroundColor Yellow
Write-Host "based on CIS Benchmark guidelines for Windows 11 Enterprise." -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Windows Firewall - Domain Profile
# =============================================================================

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "WINDOWS FIREWALL - DOMAIN PROFILE" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

$domainPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
if (-not (Test-Path $domainPath)) { New-Item -Path $domainPath -Force | Out-Null }

# Enable Windows Firewall for Domain Profile
Set-PolicyValue -PolicyId "8.1.1" -PolicyName "Windows Firewall: Domain: Firewall state" -Path $domainPath -Name "EnableFirewall" -Value 1 -Type DWord

# Block inbound connections by default
Set-PolicyValue -PolicyId "8.1.2" -PolicyName "Windows Firewall: Domain: Inbound connections" -Path $domainPath -Name "DefaultInboundAction" -Value 1 -Type DWord

# Allow outbound connections by default
Set-PolicyValue -PolicyId "8.1.3" -PolicyName "Windows Firewall: Domain: Outbound connections" -Path $domainPath -Name "DefaultOutboundAction" -Value 0 -Type DWord

# Disable notifications for blocked applications
Set-PolicyValue -PolicyId "8.1.4" -PolicyName "Windows Firewall: Domain: Display a notification" -Path $domainPath -Name "DisableNotifications" -Value 1 -Type DWord

# Logging settings
$domainLoggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
if (-not (Test-Path $domainLoggingPath)) { New-Item -Path $domainLoggingPath -Force | Out-Null }

Set-PolicyValue -PolicyId "8.1.5" -PolicyName "Windows Firewall: Domain: Logging: Name" -Path $domainLoggingPath -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\domainfw.log" -Type String

Set-PolicyValue -PolicyId "8.1.6" -PolicyName "Windows Firewall: Domain: Logging: Size limit" -Path $domainLoggingPath -Name "LogFileSize" -Value 16384 -Type DWord

Set-PolicyValue -PolicyId "8.1.7" -PolicyName "Windows Firewall: Domain: Logging: Log dropped packets" -Path $domainLoggingPath -Name "LogDroppedPackets" -Value 1 -Type DWord

Set-PolicyValue -PolicyId "8.1.8" -PolicyName "Windows Firewall: Domain: Logging: Log successful connections" -Path $domainLoggingPath -Name "LogSuccessfulConnections" -Value 1 -Type DWord

# =============================================================================
# Windows Firewall - Private Profile
# =============================================================================

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "WINDOWS FIREWALL - PRIVATE PROFILE" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

$privatePath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
if (-not (Test-Path $privatePath)) { New-Item -Path $privatePath -Force | Out-Null }

# Enable Windows Firewall for Private Profile
Set-PolicyValue -PolicyId "8.2.1" -PolicyName "Windows Firewall: Private: Firewall state" -Path $privatePath -Name "EnableFirewall" -Value 1 -Type DWord

# Block inbound connections by default
Set-PolicyValue -PolicyId "8.2.2" -PolicyName "Windows Firewall: Private: Inbound connections" -Path $privatePath -Name "DefaultInboundAction" -Value 1 -Type DWord

# Allow outbound connections by default
Set-PolicyValue -PolicyId "8.2.3" -PolicyName "Windows Firewall: Private: Outbound connections" -Path $privatePath -Name "DefaultOutboundAction" -Value 0 -Type DWord

# Disable notifications for blocked applications
Set-PolicyValue -PolicyId "8.2.4" -PolicyName "Windows Firewall: Private: Display a notification" -Path $privatePath -Name "DisableNotifications" -Value 1 -Type DWord

# Logging settings
$privateLoggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
if (-not (Test-Path $privateLoggingPath)) { New-Item -Path $privateLoggingPath -Force | Out-Null }

Set-PolicyValue -PolicyId "8.2.5" -PolicyName "Windows Firewall: Private: Logging: Name" -Path $privateLoggingPath -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\privatefw.log" -Type String

Set-PolicyValue -PolicyId "8.2.6" -PolicyName "Windows Firewall: Private: Logging: Size limit" -Path $privateLoggingPath -Name "LogFileSize" -Value 16384 -Type DWord

Set-PolicyValue -PolicyId "8.2.7" -PolicyName "Windows Firewall: Private: Logging: Log dropped packets" -Path $privateLoggingPath -Name "LogDroppedPackets" -Value 1 -Type DWord

Set-PolicyValue -PolicyId "8.2.8" -PolicyName "Windows Firewall: Private: Logging: Log successful connections" -Path $privateLoggingPath -Name "LogSuccessfulConnections" -Value 1 -Type DWord

# =============================================================================
# Windows Firewall - Public Profile
# =============================================================================

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "WINDOWS FIREWALL - PUBLIC PROFILE" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

$publicPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
if (-not (Test-Path $publicPath)) { New-Item -Path $publicPath -Force | Out-Null }

# Enable Windows Firewall for Public Profile
Set-PolicyValue -PolicyId "8.3.1" -PolicyName "Windows Firewall: Public: Firewall state" -Path $publicPath -Name "EnableFirewall" -Value 1 -Type DWord

# Block inbound connections by default
Set-PolicyValue -PolicyId "8.3.2" -PolicyName "Windows Firewall: Public: Inbound connections" -Path $publicPath -Name "DefaultInboundAction" -Value 1 -Type DWord

# Allow outbound connections by default
Set-PolicyValue -PolicyId "8.3.3" -PolicyName "Windows Firewall: Public: Outbound connections" -Path $publicPath -Name "DefaultOutboundAction" -Value 0 -Type DWord

# Disable notifications for blocked applications
Set-PolicyValue -PolicyId "8.3.4" -PolicyName "Windows Firewall: Public: Display a notification" -Path $publicPath -Name "DisableNotifications" -Value 1 -Type DWord

# Disable local firewall rules (Public should be most restrictive)
Set-PolicyValue -PolicyId "8.3.5" -PolicyName "Windows Firewall: Public: Apply local firewall rules" -Path $publicPath -Name "AllowLocalPolicyMerge" -Value 0 -Type DWord

Set-PolicyValue -PolicyId "8.3.6" -PolicyName "Windows Firewall: Public: Apply local connection security rules" -Path $publicPath -Name "AllowLocalIPsecPolicyMerge" -Value 0 -Type DWord

# Logging settings
$publicLoggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
if (-not (Test-Path $publicLoggingPath)) { New-Item -Path $publicLoggingPath -Force | Out-Null }

Set-PolicyValue -PolicyId "8.3.7" -PolicyName "Windows Firewall: Public: Logging: Name" -Path $publicLoggingPath -Name "LogFilePath" -Value "%SystemRoot%\System32\logfiles\firewall\publicfw.log" -Type String

Set-PolicyValue -PolicyId "8.3.8" -PolicyName "Windows Firewall: Public: Logging: Size limit" -Path $publicLoggingPath -Name "LogFileSize" -Value 16384 -Type DWord

Set-PolicyValue -PolicyId "8.3.9" -PolicyName "Windows Firewall: Public: Logging: Log dropped packets" -Path $publicLoggingPath -Name "LogDroppedPackets" -Value 1 -Type DWord

Set-PolicyValue -PolicyId "8.3.10" -PolicyName "Windows Firewall: Public: Logging: Log successful connections" -Path $publicLoggingPath -Name "LogSuccessfulConnections" -Value 1 -Type DWord

# =============================================================================
# Final Summary Report
# =============================================================================

$endTime = Get-Date
$duration = $endTime - $Script:StartTime

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Benchmark Section 8 Configuration Complete!" -ForegroundColor Cyan
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
        Write-Host "  Error:      " -ForegroundColor Gray -NoNewline
        Write-Host "$($err.ErrorMessage)" -ForegroundColor Red
        Write-Host ""
    }
}

# Export detailed report to file
$reportPath = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "section8_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$reportContent = @"
=============================================================================
CIS BENCHMARK SECTION 8 - EXECUTION REPORT
Windows Firewall Configuration
=============================================================================

Execution Date: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $($duration.ToString('hh\:mm\:ss'))
Computer: $env:COMPUTERNAME
User: $env:USERNAME

NOTE: This script implements standard Windows Firewall recommendations
based on CIS Benchmark guidelines. The source Section 8 markdown files
were incomplete, so this is a reference implementation.

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
  Error:     $($err.ErrorMessage)

"@
    }
}

$reportContent += @"

=============================================================================
WINDOWS FIREWALL PROFILES
=============================================================================

Domain Profile:
  Used when connected to a domain network
  Settings configured in: HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile
  Log file: %SystemRoot%\System32\logfiles\firewall\domainfw.log

Private Profile:
  Used when connected to a private/home network
  Settings configured in: HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile
  Log file: %SystemRoot%\System32\logfiles\firewall\privatefw.log

Public Profile:
  Used when connected to public networks (hotels, airports, etc.)
  Most restrictive settings applied
  Settings configured in: HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile
  Log file: %SystemRoot%\System32\logfiles\firewall\publicfw.log

=============================================================================
NOTES
=============================================================================

- All profiles configured to block inbound and allow outbound by default
- Logging enabled for all profiles (16MB log files)
- Public profile has most restrictive settings (no local rule merge)
- Firewall log files stored in: %SystemRoot%\System32\logfiles\firewall\
- A system restart may be required for all changes to take effect

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
Write-Host "- All firewall profiles are enabled with recommended settings" -ForegroundColor Yellow
Write-Host "- Inbound connections blocked by default on all profiles" -ForegroundColor Yellow
Write-Host "- Logging enabled for dropped packets and successful connections" -ForegroundColor Yellow
Write-Host "- Public profile has most restrictive settings" -ForegroundColor Yellow
Write-Host "- Run this script as Administrator" -ForegroundColor Yellow
Write-Host ""
