<#
.SYNOPSIS
    CIS Control 18.7.11 - 18.7.11 (L1) Ensure 'Manage processing of Queue-specific files' is set to 'Enabl

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Limit Queue-specific files to Color profiles :
 
Computer Configuration\Policies\Administrative Templates\Print...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.7.11
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Manage processing of Queue-specific files
    Recommended Value: Enabled: Limit Queue-specific files to Color profiles
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.7.11.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.7.11..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Manage processing of Queue-specific files"
    $value = "Enabled: Limit Queue-specific files to Color profiles"
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
        Write-Host "Successfully applied CIS Control 18.7.11" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.7.11: $_" -ForegroundColor Red
    exit 1
}
