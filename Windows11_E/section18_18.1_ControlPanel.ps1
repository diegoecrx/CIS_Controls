param([switch]$Report)

$settingsDb = Import-PowerShellDataFile -Path "$PSScriptRoot\section18_settings.psd1"
$settings = $settingsDb.Settings | Where-Object { $_.Control -match '^18\.1' }

$results = @()
Write-Host ""
Write-Host "=== Section 18.1 - Control Panel ===" -ForegroundColor Cyan
Write-Host "Configuring $($settings.Count) settings..." -ForegroundColor White

$registrySettings = @($settings | Where-Object { $_.Path -ne "N/A" })
$policyOnlySettings = @($settings | Where-Object { $_.Path -eq "N/A" })

foreach ($setting in $registrySettings) {
    try {
        $path = $setting.Path
        $name = $setting.Name
        $value = $setting.Value
        $type = $setting.Type
        
        $current = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
        $currentValue = if ($current) { $current.$name } else { "Not Set" }
        
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force | Out-Null
        
        $results += [PSCustomObject]@{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            Path = $path
            Name = $name
            CurrentValue = $currentValue
            AppliedValue = $value
            Status = "Success"
        }
        Write-Host "$($setting.Control) | $($setting.Description) | $currentValue -> $value" -ForegroundColor Green
    }
    catch {
        $results += [PSCustomObject]@{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            Path = $setting.Path
            Name = $setting.Name
            CurrentValue = "Error"
            AppliedValue = $setting.Value
            Status = "Failed: $($_.Exception.Message)"
        }
        Write-Host "$($setting.Control) - FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Summary - 18.1: Applied $(($results | Where-Object {$_.Status -eq 'Success'}).Count), Failed $(($results | Where-Object {$_.Status -ne 'Success'}).Count)" -ForegroundColor Yellow

if ($Report) {
    $results | Export-Csv -Path "$PSScriptRoot\section18_18.1_report.csv" -NoTypeInformation
}

return $results
