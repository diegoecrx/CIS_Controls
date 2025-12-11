<#
.SYNOPSIS
    CIS Control 18.9.25.1 - 18.9.25.1 (L1) Ensure 'Configure password backup directory' is set to 'Enabled: 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Active Directory or Enabled: Azure Active Directory :
 
Computer Configuration\Policies\Administrative Template...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.25.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure password backup directory
    Recommended Value: Enabled: Active Directory
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.25.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.25.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure password backup directory"
    $value = "Enabled: Active Directory"
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
        Write-Host "Successfully applied CIS Control 18.9.25.1" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.25.1: $_" -ForegroundColor Red
    exit 1
}
