<#
.SYNOPSIS
    CIS Control 18.6.7.7 - 18.6.7.7 (L1) Ensure 'Set authentication rate limiter delay (milliseconds)' is s

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 2000 or more:
 
Computer Configuration\Policies\Administrative Templates\Network\Lanman Server\Set authenticati...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.6.7.7
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Set authentication rate limiter delay (milliseconds)
    Recommended Value: Enabled: 2000
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.6.7.7.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.6.7.7..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Set authentication rate limiter delay (milliseconds)"
    $value = "Enabled: 2000"
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
        Write-Host "Successfully applied CIS Control 18.6.7.7" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.6.7.7: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
