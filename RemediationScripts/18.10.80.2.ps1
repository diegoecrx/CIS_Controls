<#
.SYNOPSIS
    CIS Control 18.10.80.2 - 18.10.80.2 (L1) Ensure 'Allow Windows Ink Workspace' is set to 'Enabled: On, but

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: On, but disallow access above lock OR Enabled: Disabled :
 
Computer Configuration\Policies\Administrative Temp...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.80.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Allow Windows Ink Workspace
    Recommended Value: Enabled: On, but disallow access above lock
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.80.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.80.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Allow Windows Ink Workspace"
    $value = "Enabled: On, but disallow access above lock"
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
        Write-Host "Successfully applied CIS Control 18.10.80.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.80.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
