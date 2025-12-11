<#
.SYNOPSIS
    CIS Control 18.5.7 - 18.5.7 (L1) Ensure 'MSS: (NoNameReleaseOnDemand) Allow the computer to ignore Ne

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Administrative Templates\MSS (Legacy)\MSS: (NoNameReleaseOnDemand) Allow the...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.7
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS: (NoNameReleaseOnDemand) Allow the computer to ignore NetBIOS name release requests except from WINS servers
    Recommended Value: Enabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.7.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.7..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS: (NoNameReleaseOnDemand) Allow the computer to ignore NetBIOS name release requests except from WINS servers"
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
        Write-Host "Successfully applied CIS Control 18.5.7" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.7: $_" -ForegroundColor Red
    exit 1
}
