<#
.SYNOPSIS
    CIS Control 18.7.2 - 18.7.2 (L1) Ensure 'Configure Redirection Guard' is set to 'Enabled: Redirection

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Redirection Guard Enabled :
 
Computer Configuration\Policies\Administrative Templates\Printers\Configure Redir...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.7.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure Redirection Guard
    Recommended Value: Enabled: Redirection Guard Enabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.7.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.7.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure Redirection Guard"
    $value = "Enabled: Redirection Guard Enabled"
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
        Write-Host "Successfully applied CIS Control 18.7.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.7.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
