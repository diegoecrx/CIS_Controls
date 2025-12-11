<#
.SYNOPSIS
    CIS Control 18.9.51.1.2 - 18.9.51.1.2 (L1) Ensure 'Enable Windows NTP Server' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Administrative Templates\System\Windows Time Service\Time Providers\Enable ...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.51.1.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Enable Windows NTP Server
    Recommended Value: Disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.51.1.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.51.1.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Enable Windows NTP Server"
    $value = 0
    $type = "DWord"
    
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
        Write-Host "Successfully applied CIS Control 18.9.51.1.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.51.1.2: $_" -ForegroundColor Red
    exit 1
}
