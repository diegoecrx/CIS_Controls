<#
.SYNOPSIS
    CIS Control 18.10.43.13.1 - 18.10.43.13.1 (L1) Ensure 'Scan excluded files and directories during quick scan

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 1 :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivirus\...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.43.13.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Scan excluded files and directories during quick scans
    Recommended Value: Enabled: 1
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.43.13.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.43.13.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Scan excluded files and directories during quick scans"
    $value = "Enabled: 1"
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
        Write-Host "Successfully applied CIS Control 18.10.43.13.1" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.43.13.1: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
