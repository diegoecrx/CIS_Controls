#Requires -RunAsAdministrator
param([switch]$Report)

# Verify running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    return @()
}

$settingsDb = (Get-Content "$PSScriptRoot\section18_settings.json" -Raw | ConvertFrom-Json)
$settings = $settingsDb.Settings | Where-Object { $_.Control -match '^18\.5\.' }

# SKIP PROBLEMATIC SETTINGS THAT MAY BREAK MICROSOFT ACCOUNT LOGIN
$settingsToSkip = @(
    '18.5.1',   # AutoAdminLogon - can block interactive login
    '18.5.10'   # ScreenSaverGracePeriod - might affect lock screen/auth
)

$settings = $settings | Where-Object { $_.Control -notin $settingsToSkip }

Write-Host ""
Write-Host "=== Section 18.5 - MSS Legacy Settings ===" -ForegroundColor Cyan
Write-Host "Configuring $($settings.Count) settings (skipping $($settingsToSkip.Count) problematic ones)..." -ForegroundColor White

if ($settingsToSkip.Count -gt 0) {
    Write-Host "Skipped settings (may affect Microsoft Account login):" -ForegroundColor Yellow
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
Write-Host "Summary - 18.5: Applied $successCount, Failed $failCount, Skipped $($settingsToSkip.Count)" -ForegroundColor Yellow
Write-Host "Note: Skipped settings may affect Microsoft Account authentication." -ForegroundColor Cyan

if ($Report) {
    $results | Export-Csv -Path "$PSScriptRoot\section18_18_5_report.csv" -NoTypeInformation
}

return $results