<#
.SYNOPSIS
    CIS Control 18.4.3 - 18.4.3 (L1) Ensure 'Configure SMB v1 server' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Administrative Templates\MS Security Guide\Configure SMB v1 server
 
Note: ...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.4.3
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure SMB v1 server
    Recommended Value: Disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.4.3.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.4.3..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure SMB v1 server"
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
        Write-Host "Successfully applied CIS Control 18.4.3" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.4.3: $_" -ForegroundColor Red
    exit 1
}
