<#
.SYNOPSIS
    CIS Control 18.10.44.5 - 18.10.44.5 (L1) Ensure 'Configure Microsoft Defender Application Guard clipboard

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Enable clipboard operation from an isolated session to the host
 
Computer Configuration\Policies\Administrativ...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.44.5
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Configure Microsoft Defender Application Guard clipboard settings: Clipboard behavior setting
    Recommended Value: Enabled: Enable clipboard operation from an isolated session to the host
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.44.5.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.44.5..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Configure Microsoft Defender Application Guard clipboard settings: Clipboard behavior setting"
    $value = "Enabled: Enable clipboard operation from an isolated session to the host"
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
        Write-Host "Successfully applied CIS Control 18.10.44.5" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.44.5: $_" -ForegroundColor Red
    exit 1
}
