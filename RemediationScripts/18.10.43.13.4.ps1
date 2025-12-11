<#
.SYNOPSIS
    CIS Control 18.10.43.13.4 - 18.10.43.13.4 (L1) Ensure 'Trigger a quick scan after X days without any scans' 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 7 days:
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivi...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.43.13.4
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Trigger a quick scan after X days without any scans
    Recommended Value: Enabled: 7
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.43.13.4.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.43.13.4..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Trigger a quick scan after X days without any scans"
    $value = "Enabled: 7"
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
        Write-Host "Successfully applied CIS Control 18.10.43.13.4" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.43.13.4: $_" -ForegroundColor Red
    exit 1
}
