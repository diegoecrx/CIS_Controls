<#
.SYNOPSIS
    CIS Control 18.10.44.6 - 18.10.44.6 (L1) Ensure 'Turn on Microsoft Defender Application Guard in Managed 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 1 :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defender Applicatio...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.44.6
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Turn on Microsoft Defender Application Guard in Managed Mode
    Recommended Value: Enabled: 1
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.44.6.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.44.6..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Turn on Microsoft Defender Application Guard in Managed Mode"
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
        Write-Host "Successfully applied CIS Control 18.10.44.6" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.44.6: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
