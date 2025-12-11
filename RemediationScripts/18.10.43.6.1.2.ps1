<#
.SYNOPSIS
    CIS Control 18.10.43.6.1.2 - 18.10.43.6.1.2 (L1) Ensure 'Configure Attack Surface Reduction rules: Set the st

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path so that 26190899-1602-49e8-8b27-eb1d0a1ce869 3b576869-a4ec-4529-8536-b80a7769e899 56a863a9-875e-4185-98a7-b882c64b5ce5 5beb...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.43.6.1.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Configure Attack Surface Reduction rules: Set the state for each ASR rule
    Recommended Value: See CIS Benchmark
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.43.6.1.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.43.6.1.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Configure Attack Surface Reduction rules: Set the state for each ASR rule"
    $value = 1
    $type = "DWord"
    
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
        Write-Host "Successfully applied CIS Control 18.10.43.6.1.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.43.6.1.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
