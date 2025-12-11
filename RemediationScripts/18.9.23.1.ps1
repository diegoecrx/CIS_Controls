<#
.SYNOPSIS
    CIS Control 18.9.23.1 - 18.9.23.1 (L2) Ensure 'Support device authentication using certificate' is set t

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Automatic :
 
Computer Configuration\Policies\Administrative Templates\System\Kerberos\Support device authentic...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.23.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Support device authentication using certificate
    Recommended Value: Enabled: Automatic
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.23.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.23.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Support device authentication using certificate"
    $value = "Enabled: Automatic"
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
        Write-Host "Successfully applied CIS Control 18.9.23.1" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.23.1: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
