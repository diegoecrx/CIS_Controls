<#
.SYNOPSIS
    CIS Control 18.9.25.8 - 18.9.25.8 (L1) Ensure 'Post-authentication actions: Actions' is set to 'Enabled:

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Reset the password and logoff the managed account or higher:
 
Computer Configuration\Policies\Administrative T...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.25.8
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Post-authentication actions: Actions
    Recommended Value: Enabled: Reset the password and logoff the managed account
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.25.8.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.25.8..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Post-authentication actions: Actions"
    $value = "Enabled: Reset the password and logoff the managed account"
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
        Write-Host "Successfully applied CIS Control 18.9.25.8" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.25.8: $_" -ForegroundColor Red
    exit 1
}
