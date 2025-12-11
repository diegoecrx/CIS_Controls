<#
.SYNOPSIS
    CIS Control 18.10.4.2 - 18.10.4.2 (L1) Ensure 'Not allow per-user unsigned packages to install by defaul

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\App Package Deployment\Not allow...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.4.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Not allow per-user unsigned packages to install by default (requires explicitly allow per install)
    Recommended Value: Enabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.4.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.4.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Not allow per-user unsigned packages to install by default (requires explicitly allow per install)"
    $value = 1
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
        Write-Host "Successfully applied CIS Control 18.10.4.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.4.2: $_" -ForegroundColor Red
    exit 1
}
