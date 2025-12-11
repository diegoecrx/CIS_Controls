<#
.SYNOPSIS
    CIS Control 18.9.25.4 - 18.9.25.4 (L1) Ensure 'Password Settings: Password Complexity' is set to 'Enable

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled and configure the Password Complexity option to Large letters + small letters + numbers + special characters :
 ...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.25.4
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Password Settings
    Recommended Value: Enabled: Large letters + small letters + numbers + special characters
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.25.4.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.25.4..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Password Settings"
    $value = "Enabled: Large letters + small letters + numbers + special characters"
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
        Write-Host "Successfully applied CIS Control 18.9.25.4" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.25.4: $_" -ForegroundColor Red
    exit 1
}
