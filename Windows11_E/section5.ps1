# =============================================================================
# CIS Windows 11 Enterprise Benchmark - Section 5
# System Services
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

# Function to get current service startup type
function Get-ServiceStartType {
    param ([string]$ServiceName)
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($null -eq $service) {
            return "Not Installed"
        }
        
        $startType = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name "Start" -ErrorAction SilentlyContinue).Start
        switch ($startType) {
            0 { return "Boot" }
            1 { return "System" }
            2 { return "Automatic" }
            3 { return "Manual" }
            4 { return "Disabled" }
            default { return "Unknown ($startType)" }
        }
    }
    catch {
        return "(Error Reading)"
    }
}

# Function to set service startup type with logging
function Set-ServiceStartupType {
    param (
        [string]$PolicyId,
        [string]$PolicyName,
        [string]$ServiceName,
        [int]$StartType = 4,  # 4 = Disabled
        [string]$Level = "L1"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    
    $startTypeNames = @{
        0 = "Boot"
        1 = "System"
        2 = "Automatic"
        3 = "Manual"
        4 = "Disabled"
    }
    
    $beforeValue = Get-ServiceStartType -ServiceName $ServiceName
    $targetValue = $startTypeNames[$StartType]
    
    # Check if service exists
    if ($beforeValue -eq "Not Installed") {
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = $regPath
            Property    = "Start"
            BeforeValue = "Not Installed"
            AfterValue  = "Not Installed (Compliant)"
            Status      = "Success"
            Level       = $Level
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Service:  $ServiceName" -ForegroundColor Gray
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "Not Installed" -ForegroundColor Yellow
        Write-Host "  After:  " -ForegroundColor Gray -NoNewline
        Write-Host "Not Installed (Compliant - service not present)" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    
    try {
        # Stop service if running
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Running') {
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        }
        
        # Set startup type via registry
        Set-ItemProperty -Path $regPath -Name "Start" -Value $StartType -Type DWord -Force -ErrorAction Stop
        
        $afterValue = Get-ServiceStartType -ServiceName $ServiceName
        
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = $regPath
            Property    = "Start"
            BeforeValue = $beforeValue
            AfterValue  = $afterValue
            Status      = "Success"
            Level       = $Level
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Service:  $ServiceName" -ForegroundColor Gray
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "$beforeValue" -ForegroundColor Yellow
        Write-Host "  After:  " -ForegroundColor Gray -NoNewline
        Write-Host "$afterValue" -ForegroundColor Green
        Write-Host ""
        
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        
        $Script:Changes += [PSCustomObject]@{
            Timestamp   = $timestamp
            PolicyId    = $PolicyId
            PolicyName  = $PolicyName
            Path        = $regPath
            Property    = "Start"
            BeforeValue = $beforeValue
            AfterValue  = "(Failed)"
            Status      = "Error"
            Level       = $Level
        }
        
        $Script:Errors += [PSCustomObject]@{
            Timestamp    = $timestamp
            PolicyId     = $PolicyId
            PolicyName   = $PolicyName
            Path         = $regPath
            Property     = "Start"
            ErrorMessage = $errorMsg
        }
        
        Write-Host "[$PolicyId] " -ForegroundColor Cyan -NoNewline
        Write-Host "$PolicyName" -ForegroundColor White
        Write-Host "  Service:  $ServiceName" -ForegroundColor Gray
        Write-Host "  Before: " -ForegroundColor Gray -NoNewline
        Write-Host "$beforeValue" -ForegroundColor Yellow
        Write-Host "  ERROR:  " -ForegroundColor Red -NoNewline
        Write-Host "$errorMsg" -ForegroundColor Red
        Write-Host ""
        
        return $false
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Windows 11 Enterprise Benchmark - Section 5" -ForegroundColor Cyan
Write-Host "System Services Configuration" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Start Time: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# Level 2 (L2) Services - High Security Environments
# =============================================================================

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "LEVEL 2 (L2) SERVICES - High Security Environments" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# 5.1 (L2) Bluetooth Audio Gateway Service
Set-ServiceStartupType -PolicyId "5.1" -PolicyName "Bluetooth Audio Gateway Service (BTAGService)" -ServiceName "BTAGService" -Level "L2"

# 5.2 (L2) Bluetooth Support Service
Set-ServiceStartupType -PolicyId "5.2" -PolicyName "Bluetooth Support Service (bthserv)" -ServiceName "bthserv" -Level "L2"

# 5.4 (L2) Downloaded Maps Manager
Set-ServiceStartupType -PolicyId "5.4" -PolicyName "Downloaded Maps Manager (MapsBroker)" -ServiceName "MapsBroker" -Level "L2"

# 5.5 (L2) GameInput Service
Set-ServiceStartupType -PolicyId "5.5" -PolicyName "GameInput Service (GameInputSvc)" -ServiceName "GameInputSvc" -Level "L2"

# 5.6 (L2) Geolocation Service
Set-ServiceStartupType -PolicyId "5.6" -PolicyName "Geolocation Service (lfsvc)" -ServiceName "lfsvc" -Level "L2"

# 5.9 (L2) Link-Layer Topology Discovery Mapper
Set-ServiceStartupType -PolicyId "5.9" -PolicyName "Link-Layer Topology Discovery Mapper (lltdsvc)" -ServiceName "lltdsvc" -Level "L2"

# 5.12 (L2) Microsoft iSCSI Initiator Service
Set-ServiceStartupType -PolicyId "5.12" -PolicyName "Microsoft iSCSI Initiator Service (MSiSCSI)" -ServiceName "MSiSCSI" -Level "L2"

# 5.14 (L2) Print Spooler
Set-ServiceStartupType -PolicyId "5.14" -PolicyName "Print Spooler (Spooler)" -ServiceName "Spooler" -Level "L2"

# 5.15 (L2) Problem Reports and Solutions Control Panel Support
Set-ServiceStartupType -PolicyId "5.15" -PolicyName "Problem Reports and Solutions Control Panel Support (wercplsupport)" -ServiceName "wercplsupport" -Level "L2"

# 5.16 (L2) Remote Access Auto Connection Manager
Set-ServiceStartupType -PolicyId "5.16" -PolicyName "Remote Access Auto Connection Manager (RasAuto)" -ServiceName "RasAuto" -Level "L2"

# 5.17 (L2) Remote Desktop Configuration
Set-ServiceStartupType -PolicyId "5.17" -PolicyName "Remote Desktop Configuration (SessionEnv)" -ServiceName "SessionEnv" -Level "L2"

# 5.18 (L2) Remote Desktop Services
Set-ServiceStartupType -PolicyId "5.18" -PolicyName "Remote Desktop Services (TermService)" -ServiceName "TermService" -Level "L2"

# 5.19 (L2) Remote Desktop Services UserMode Port Redirector
Set-ServiceStartupType -PolicyId "5.19" -PolicyName "Remote Desktop Services UserMode Port Redirector (UmRdpService)" -ServiceName "UmRdpService" -Level "L2"

# 5.21 (L2) Remote Registry
Set-ServiceStartupType -PolicyId "5.21" -PolicyName "Remote Registry (RemoteRegistry)" -ServiceName "RemoteRegistry" -Level "L2"

# 5.23 (L2) Server
Set-ServiceStartupType -PolicyId "5.23" -PolicyName "Server (LanmanServer)" -ServiceName "LanmanServer" -Level "L2"

# 5.25 (L2) SNMP Service
Set-ServiceStartupType -PolicyId "5.25" -PolicyName "SNMP Service (SNMP)" -ServiceName "SNMP" -Level "L2"

# 5.30 (L2) Windows Error Reporting Service
Set-ServiceStartupType -PolicyId "5.30" -PolicyName "Windows Error Reporting Service (WerSvc)" -ServiceName "WerSvc" -Level "L2"

# 5.31 (L2) Windows Event Collector
Set-ServiceStartupType -PolicyId "5.31" -PolicyName "Windows Event Collector (Wecsvc)" -ServiceName "Wecsvc" -Level "L2"

# 5.34 (L2) Windows Push Notifications System Service
Set-ServiceStartupType -PolicyId "5.34" -PolicyName "Windows Push Notifications System Service (WpnService)" -ServiceName "WpnService" -Level "L2"

# 5.35 (L2) Windows PushToInstall Service
Set-ServiceStartupType -PolicyId "5.35" -PolicyName "Windows PushToInstall Service (PushToInstall)" -ServiceName "PushToInstall" -Level "L2"

# 5.36 (L2) Windows Remote Management (WS-Management)
Set-ServiceStartupType -PolicyId "5.36" -PolicyName "Windows Remote Management (WS-Management) (WinRM)" -ServiceName "WinRM" -Level "L2"

# 5.37 (L2) WinHTTP Web Proxy Auto-Discovery Service
Set-ServiceStartupType -PolicyId "5.37" -PolicyName "WinHTTP Web Proxy Auto-Discovery Service (WinHttpAutoProxySvc)" -ServiceName "WinHttpAutoProxySvc" -Level "L2"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "LEVEL 1 (L1) SERVICES - Standard Security" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""

# =============================================================================
# Level 1 (L1) Services - Standard Security
# =============================================================================

# 5.3 (L1) Computer Browser
Set-ServiceStartupType -PolicyId "5.3" -PolicyName "Computer Browser (Browser)" -ServiceName "Browser" -Level "L1"

# 5.7 (L1) IIS Admin Service
Set-ServiceStartupType -PolicyId "5.7" -PolicyName "IIS Admin Service (IISADMIN)" -ServiceName "IISADMIN" -Level "L1"

# 5.8 (L1) Infrared monitor service
Set-ServiceStartupType -PolicyId "5.8" -PolicyName "Infrared monitor service (irmon)" -ServiceName "irmon" -Level "L1"

# 5.10 (L1) LxssManager (Windows Subsystem for Linux)
Set-ServiceStartupType -PolicyId "5.10" -PolicyName "LxssManager (LxssManager)" -ServiceName "LxssManager" -Level "L1"

# 5.11 (L1) Microsoft FTP Service
Set-ServiceStartupType -PolicyId "5.11" -PolicyName "Microsoft FTP Service (FTPSVC)" -ServiceName "FTPSVC" -Level "L1"

# 5.13 (L1) OpenSSH SSH Server
Set-ServiceStartupType -PolicyId "5.13" -PolicyName "OpenSSH SSH Server (sshd)" -ServiceName "sshd" -Level "L1"

# 5.20 (L1) Remote Procedure Call (RPC) Locator
Set-ServiceStartupType -PolicyId "5.20" -PolicyName "Remote Procedure Call (RPC) Locator (RpcLocator)" -ServiceName "RpcLocator" -Level "L1"

# 5.22 (L1) Routing and Remote Access
Set-ServiceStartupType -PolicyId "5.22" -PolicyName "Routing and Remote Access (RemoteAccess)" -ServiceName "RemoteAccess" -Level "L1"

# 5.24 (L1) Simple TCP/IP Services
Set-ServiceStartupType -PolicyId "5.24" -PolicyName "Simple TCP/IP Services (simptcp)" -ServiceName "simptcp" -Level "L1"

# 5.26 (L1) Special Administration Console Helper
Set-ServiceStartupType -PolicyId "5.26" -PolicyName "Special Administration Console Helper (sacsvr)" -ServiceName "sacsvr" -Level "L1"

# 5.27 (L1) SSDP Discovery
Set-ServiceStartupType -PolicyId "5.27" -PolicyName "SSDP Discovery (SSDPSRV)" -ServiceName "SSDPSRV" -Level "L1"

# 5.28 (L1) UPnP Device Host
Set-ServiceStartupType -PolicyId "5.28" -PolicyName "UPnP Device Host (upnphost)" -ServiceName "upnphost" -Level "L1"

# 5.29 (L1) Web Management Service
Set-ServiceStartupType -PolicyId "5.29" -PolicyName "Web Management Service (WMSvc)" -ServiceName "WMSvc" -Level "L1"

# 5.32 (L1) Windows Media Player Network Sharing Service
Set-ServiceStartupType -PolicyId "5.32" -PolicyName "Windows Media Player Network Sharing Service (WMPNetworkSvc)" -ServiceName "WMPNetworkSvc" -Level "L1"

# 5.33 (L1) Windows Mobile Hotspot Service
Set-ServiceStartupType -PolicyId "5.33" -PolicyName "Windows Mobile Hotspot Service (icssvc)" -ServiceName "icssvc" -Level "L1"

# 5.38 (L1) World Wide Web Publishing Service
Set-ServiceStartupType -PolicyId "5.38" -PolicyName "World Wide Web Publishing Service (W3SVC)" -ServiceName "W3SVC" -Level "L1"

# 5.39 (L1) Xbox Accessory Management Service
Set-ServiceStartupType -PolicyId "5.39" -PolicyName "Xbox Accessory Management Service (XboxGipSvc)" -ServiceName "XboxGipSvc" -Level "L1"

# 5.40 (L1) Xbox Live Auth Manager
Set-ServiceStartupType -PolicyId "5.40" -PolicyName "Xbox Live Auth Manager (XblAuthManager)" -ServiceName "XblAuthManager" -Level "L1"

# 5.41 (L1) Xbox Live Game Save
Set-ServiceStartupType -PolicyId "5.41" -PolicyName "Xbox Live Game Save (XblGameSave)" -ServiceName "XblGameSave" -Level "L1"

# 5.42 (L1) Xbox Live Networking Service
Set-ServiceStartupType -PolicyId "5.42" -PolicyName "Xbox Live Networking Service (XboxNetApiSvc)" -ServiceName "XboxNetApiSvc" -Level "L1"

# =============================================================================
# Final Summary Report
# =============================================================================

$endTime = Get-Date
$duration = $endTime - $Script:StartTime

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CIS Benchmark Section 5 Configuration Complete!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Summary Statistics
$successCount = ($Script:Changes | Where-Object { $_.Status -eq "Success" }).Count
$errorCount = $Script:Errors.Count
$totalChanges = $Script:Changes.Count
$l1Count = ($Script:Changes | Where-Object { $_.Level -eq "L1" }).Count
$l2Count = ($Script:Changes | Where-Object { $_.Level -eq "L2" }).Count
$notInstalledCount = ($Script:Changes | Where-Object { $_.BeforeValue -eq "Not Installed" }).Count

Write-Host "EXECUTION SUMMARY" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow
Write-Host "Start Time:        $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "End Time:          $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
Write-Host "Duration:          $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "Total Services:    $totalChanges" -ForegroundColor White
Write-Host "  Level 1 (L1):    $l1Count" -ForegroundColor White
Write-Host "  Level 2 (L2):    $l2Count" -ForegroundColor White
Write-Host "Not Installed:     $notInstalledCount" -ForegroundColor White
Write-Host ""
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
$reportPath = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "section5_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$reportContent = @"
=============================================================================
CIS BENCHMARK SECTION 5 - EXECUTION REPORT
System Services Configuration
=============================================================================

Execution Date: $($Script:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $($duration.ToString('hh\:mm\:ss'))
Computer: $env:COMPUTERNAME
User: $env:USERNAME

SUMMARY
-------
Total Services Processed: $totalChanges
  Level 1 (L1): $l1Count
  Level 2 (L2): $l2Count
Not Installed (Compliant): $notInstalledCount
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
  Level:        $($change.Level)
  Path:         $($change.Path)
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
NOTES
=============================================================================

Level 1 (L1) - Standard Security:
  These services should be disabled on all enterprise workstations.
  They represent common attack vectors or unnecessary functionality.

Level 2 (L2) - High Security Environments:
  These services should be disabled in high-security environments.
  Some may impact functionality (printing, remote management, etc.)
  Evaluate impact before deploying in production.

Important Considerations:
- Print Spooler (5.14): Disabling prevents all printing capabilities
- Remote Desktop Services (5.18): Disabling prevents RDP connections
- Server (5.23): Disabling prevents file/print sharing from this machine
- WinRM (5.36): Disabling prevents PowerShell remoting and some SCCM features

Services marked "Not Installed" are already compliant and require no action.

A system restart may be required for changes to take full effect.

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

Write-Host "IMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "================" -ForegroundColor Yellow
Write-Host "- Level 2 (L2) settings may impact functionality (printing, RDP, etc.)" -ForegroundColor Yellow
Write-Host "- Test in a non-production environment before deployment" -ForegroundColor Yellow
Write-Host "- Services marked 'Not Installed' are already compliant" -ForegroundColor Yellow
Write-Host "- A system restart may be required for all changes to take effect" -ForegroundColor Yellow
Write-Host "- Run this script as Administrator" -ForegroundColor Yellow
Write-Host ""
