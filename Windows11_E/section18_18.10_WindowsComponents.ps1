#Requires -RunAsAdministrator
param([switch]$Report)

# Helper function to get REAL policy values - MUST BE DEFINED FIRST
function Get-RealPolicyValue {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Type
    )
    
    # Try to get the value directly from registry
    try {
        if (Test-Path -Path $Path) {
            $regValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            if ($null -ne $regValue -and $null -ne $regValue.$Name) {
                return $regValue.$Name
            }
        }
    } catch { }
    
    # If not in registry, check for default/effective policy value
    # Different policies have different defaults when not configured
    
    # Common Windows Components defaults
    $policyDefaults = @{
        # Camera settings - usually enabled (1) by default
        "AllowCamera" = 0  # Default is enabled, but we want to see 0 for "not configured"
        "NoLockScreenCamera" = 0
        "NoLockScreenSlideshow" = 0
        
        # Privacy settings
        "AllowTelemetry" = 3  # Windows 10/11 default is "Enhanced" (3)
        "AllowInputPersonalization" = 1  # Usually enabled by default
        
        # Windows Update defaults
        "NoAutoUpdate" = 0  # Auto-updates enabled by default
        "AutoDownload" = 4  # Auto download and schedule install
        
        # Windows Defender defaults
        "DisableRealtimeMonitoring" = 0  # Real-time protection ON by default
        "DisableBehaviorMonitoring" = 0  # Behavior monitoring ON by default
        
        # Cortana/Windows Search
        "AllowCortana" = 1  # Usually enabled by default
        "AllowCortanaAboveLock" = 1  # Usually enabled by default
    }
    
    # Check if this policy has a known default
    if ($policyDefaults.ContainsKey($Name)) {
        return $policyDefaults[$Name]
    }
    
    # For DWord values, 0 often means "not configured" or "disabled"
    # For enabled/disabled policies, 0 usually means "not configured" (use system default)
    switch ($Type) {
        "DWord" { return 0 }
        "String" { return "" }
        "Binary" { return @() }
        default { return "Unknown" }
    }
}

# Verify running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    return @()
}

$settingsDb = (Get-Content "$PSScriptRoot\section18_settings.json" -Raw | ConvertFrom-Json)
$settings = $settingsDb.Settings | Where-Object { $_.Control -match '^18\.10\.' }

$results = @()
Write-Host ""
Write-Host "=== Section 18.10 - Windows Components ===" -ForegroundColor Cyan
Write-Host "Configuring $($settings.Count) settings..." -ForegroundColor White
Write-Host ""

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
    
    # Get REAL current value - check registry AND group policy
    $currentValue = Get-RealPolicyValue -Path $path -Name $name -Type $type
    
    # Apply the setting
    try {
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -Force -ErrorAction Stop | Out-Null
        }
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force -ErrorAction Stop | Out-Null
        
        # Get actual applied value
        Start-Sleep -Milliseconds 100  # Brief pause for registry to update
        $verify = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
        $actualValue = $verify.$name
        
        # Check if policy is truly effective
        $effectiveValue = Get-RealPolicyValue -Path $path -Name $name -Type $type
        
        $results += New-Object PSObject -Property @{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            RegistryPath = $setting.Path
            PolicyName = $name
            BeforeValue = $currentValue
            AfterValue = $actualValue
            EffectiveValue = $effectiveValue
            TargetValue = $value
            Status = if ($actualValue -eq $value) { "Success" } else { "Failed" }
            Notes = if ($effectiveValue -ne $actualValue) { "Policy may be overridden by GPO" } else { "" }
        }
        
        if ($actualValue -eq $value) {
            Write-Host "✓ $($setting.Control) - $($setting.Description)" -ForegroundColor Green
            Write-Host "  Before: $currentValue | After: $actualValue | Effective: $effectiveValue" -ForegroundColor Gray
        } else {
            Write-Host "✗ $($setting.Control) - $($setting.Description)" -ForegroundColor Red
            Write-Host "  Before: $currentValue | After: $actualValue (Target: $value) | Effective: $effectiveValue" -ForegroundColor Yellow
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        $results += New-Object PSObject -Property @{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            RegistryPath = $setting.Path
            PolicyName = $name
            BeforeValue = $currentValue
            AfterValue = "ERROR"
            EffectiveValue = "ERROR"
            TargetValue = $value
            Status = "Error"
            Notes = $errorMsg
        }
        Write-Host "✗ $($setting.Control) - $($setting.Description)" -ForegroundColor Red
        Write-Host "  ERROR: $errorMsg" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Summary
$successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "Failed" }).Count
$errorCount = ($results | Where-Object { $_.Status -eq "Error" }).Count

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total settings: $($settings.Count)" -ForegroundColor White
Write-Host "Successfully applied: $successCount" -ForegroundColor Green
Write-Host "Failed to apply: $failCount" -ForegroundColor Yellow
Write-Host "Errors: $errorCount" -ForegroundColor Red

# Show problematic settings
$problematic = $results | Where-Object { $_.Status -ne "Success" }
if ($problematic) {
    Write-Host ""
    Write-Host "=== PROBLEMATIC SETTINGS ===" -ForegroundColor Yellow
    foreach ($problem in $problematic) {
        Write-Host "  $($problem.Control) - $($problem.Status): $($problem.Notes)" -ForegroundColor Yellow
    }
}

# Export results if requested
if ($Report) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = "$PSScriptRoot\section18_18.10_report_$timestamp.csv"
    $results | Export-Csv -Path $reportPath -NoTypeInformation
    Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
}

return $results