<#
.SYNOPSIS
    CIS Control 18.9.25.7 - 18.9.25.7 (L1) Ensure 'Post-authentication actions: Grace period (hours)' is set

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 8 or fewer hours, but not 0 :
 
Computer Configuration\Policies\Administrative Templates\System\LAPS\Post-authe...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.25.7
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Post-authentication actions: Grace period (hours)
    Recommended Value: Enabled: 8 or fewer hours, but not 0
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.25.7.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.25.7..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Post-authentication actions: Grace period (hours)"
    $value = "Enabled: 8 or fewer hours, but not 0"
    $type = "String"
    
    # Ensure the registry path exists
    if (-not (Test-Path $regPath)) {
        Write-Host "Creating registry path: $regPath"
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Set the registry value
    Write-Host "Setting $valueName = $value"
    Set-ItemProperty -Path $regPath -Name $valueName -Value $value -Type $type -Force
    
    # Verify the setting
    $currentValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
    if ($currentValue.$valueName -eq $value) {
        Write-Host "Successfully applied CIS Control 18.9.25.7" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.25.7: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
