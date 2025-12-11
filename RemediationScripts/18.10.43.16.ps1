<#
.SYNOPSIS
    CIS Control 18.10.43.16 - 18.10.43.16 (L1) Ensure 'Configure detection for potentially unwanted applicatio

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Block :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Antivi...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.43.16
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Configure detection for potentially unwanted applications
    Recommended Value: Enabled: Block
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.43.16.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.43.16..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Configure detection for potentially unwanted applications"
    $value = "Enabled: Block"
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
        Write-Host "Successfully applied CIS Control 18.10.43.16" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.43.16: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
