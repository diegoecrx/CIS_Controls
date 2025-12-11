<#
.SYNOPSIS
    CIS Control 18.4.2 - 18.4.2 (L1) Ensure 'Configure SMB v1 client driver' is set to 'Enabled: Disable 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Disable driver (recommended) :
 
Computer Configuration\Policies\Administrative Templates\MS Security Guide\Con...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.4.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure SMB v1 client driver
    Recommended Value: Enabled: Disable driver (recommended)
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.4.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.4.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure SMB v1 client driver"
    $value = "Enabled: Disable driver (recommended)"
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
        Write-Host "Successfully applied CIS Control 18.4.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.4.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
