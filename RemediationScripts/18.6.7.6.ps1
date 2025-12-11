<#
.SYNOPSIS
    CIS Control 18.6.7.6 - 18.6.7.6 (L1) Ensure 'Mandate the minimum version of SMB' is set to 'Enabled: 3.

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 3.1.1 :
 
Computer Configuration\Policies\Administrative Templates\Network\Lanman Server\Mandate the minimum ve...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.6.7.6
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Mandate the minimum version of SMB
    Recommended Value: Enabled: 3.1.1
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.6.7.6.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.6.7.6..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Mandate the minimum version of SMB"
    $value = "Enabled: 3.1.1"
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
        Write-Host "Successfully applied CIS Control 18.6.7.6" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.6.7.6: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
