<#
.SYNOPSIS
    CIS Control 18.9.25.5 - 18.9.25.5 (L1) Ensure 'Password Settings: Password Length' is set to 'Enabled: 1

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled and configure the Password Length option to 15 or more :
 
Computer Configuration\Policies\Administrative Templa...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.25.5
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Password Settings
    Recommended Value: Enabled: 15 or more
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.25.5.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.25.5..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Password Settings"
    $value = "Enabled: 15 or more"
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
        Write-Host "Successfully applied CIS Control 18.9.25.5" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.25.5: $_" -ForegroundColor Red
    exit 1
}
