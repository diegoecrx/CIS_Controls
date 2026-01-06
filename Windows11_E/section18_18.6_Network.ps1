#Requires -RunAsAdministrator
param([switch]$Report)

# Verify running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    return @()
}

$settingsDb = (Get-Content "$PSScriptRoot\section18_settings.json" -Raw | ConvertFrom-Json)
$settings = $settingsDb.Settings | Where-Object { $_.Control -match '^18\.6\.' }

# SKIP PROBLEMATIC SETTINGS THAT MAY BREAK MICROSOFT ACCOUNT LOGIN OR NETWORK AUTH
$settingsToSkip = @(
    '18.6.4.2',   # Configure NetBIOS settings - may affect legacy auth methods
    '18.6.21.2',  # Prohibit connection to non-domain networks - blocks Microsoft Account auth
    '18.6.11.4'   # Require domain users to elevate when setting network location - may cause UAC issues
)

$settings = $settings | Where-Object { $_.Control -notin $settingsToSkip }

Write-Host ""
Write-Host "=== Section 18.6 - Network ===" -ForegroundColor Cyan
Write-Host "Configuring $($settings.Count) settings (skipping $($settingsToSkip.Count) problematic ones)..." -ForegroundColor White

if ($settingsToSkip.Count -gt 0) {
    Write-Host "Skipped settings (may affect authentication/network connectivity):" -ForegroundColor Yellow
    foreach ($skip in $settingsToSkip) {
        Write-Host "  - $skip" -ForegroundColor Gray
    }
    Write-Host ""
}

$results = @()
$registrySettings = @($settings | Where-Object { $_.Path -ne "N/A" })

foreach ($setting in $registrySettings) {
    $path = $setting.Path
    if ($path -like 'HKLM\*') {
        $path = $path -replace '^HKLM\\', 'HKLM:\'
    } elseif ($path -like 'HKCU\*') {
        $path = $path -replace '^HKCU\\', 'HKCU:\'
    }
    $name = $setting.Name
    $value = $setting.Value
    $type = $setting.Type
    
    # Get current value (show NULL if not set)
    $currentValue = "NULL"
    try {
        if (Test-Path -Path $path) {
            $current = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
            if ($null -ne $current -and $null -ne $current.$name) {
                $currentValue = $current.$name
            }
        }
    } catch { }
    
    # Apply the setting
    try {
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -Force -ErrorAction Stop | Out-Null
        }
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force -ErrorAction Stop | Out-Null
        
        # Verify the write
        $verify = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
        $actualValue = $verify.$name
        
        $results += New-Object PSObject -Property @{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            PreviousValue = $currentValue
            AppliedValue = $actualValue
            Status = "Success"
        }
        Write-Host "$($setting.Control) | $($setting.Description) | $currentValue -> $actualValue" -ForegroundColor Green
    }
    catch {
        $errorMsg = $_.Exception.Message
        $results += New-Object PSObject -Property @{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            PreviousValue = $currentValue
            AppliedValue = "FAILED"
            Status = "Failed: $errorMsg"
        }
        Write-Host "$($setting.Control) | $($setting.Description) | FAILED: $errorMsg" -ForegroundColor Red
    }
}

$successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
$failCount = ($results | Where-Object { $_.Status -ne "Success" }).Count

Write-Host ""
Write-Host "Summary - 18.6: Applied $successCount, Failed $failCount, Skipped $($settingsToSkip.Count)" -ForegroundColor Yellow
Write-Host "Note: Skipped settings may affect network authentication and Microsoft Account login." -ForegroundColor Cyan
Write-Host ""

# Additional safety check for network connectivity
Write-Host "=== Network Connectivity Check ===" -ForegroundColor Cyan
try {
    # Try a more reliable connectivity check
    $testResult = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -ErrorAction SilentlyContinue
    if ($testResult) {
        Write-Host "✓ Basic network connectivity verified" -ForegroundColor Green
    } else {
        Write-Host "⚠ Network connectivity may be restricted - checking local network..." -ForegroundColor Yellow
        $localGateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop
        if ($localGateway) {
            Write-Host "  Local gateway: $localGateway" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "⚠ Unable to verify network connectivity" -ForegroundColor Yellow
}

# Check if any network services were disabled that might affect connectivity
$disabledServices = @("PeerDistSvc", "p2psvc", "p2pimsvc", "PNRPsvc")
foreach ($service in $disabledServices) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Stopped") {
        Write-Host "⚠ Service '$service' is stopped (may be intentional for security)" -ForegroundColor Yellow
    }
}

if ($Report) {
    $results | Export-Csv -Path "$PSScriptRoot\section18_18_6_report.csv" -NoTypeInformation
}

return $results