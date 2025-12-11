<#
.SYNOPSIS
    CIS Control 1.2.4 - 1.2.4 (L1) Ensure 'Reset account lockout counter after' is set to '15 or more mi

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 15 :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Account Policies\Account Loc...

.NOTES
    This script requires administrative privileges.
    It modifies local security policy settings.
    
    CIS Control: 1.2.4
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\1.2.4.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 1.2.4..." -ForegroundColor Cyan

try {
    # Export current security policy
    $tempFile = [System.IO.Path]::GetTempFileName()
    $tempCfg = [System.IO.Path]::GetTempFileName()
    
    secedit /export /cfg $tempFile /quiet
    
    # Read and update the policy
    $policyContent = Get-Content $tempFile
    $newContent = @()
    $settingFound = $false
    
    foreach ($line in $policyContent) {
        if ($line -match "^ResetLockoutCount\s*=") {
            $newContent += "ResetLockoutCount = 15"
            $settingFound = $true
        } else {
            $newContent += $line
        }
    }
    
    if (-not $settingFound) {
        $newContent += "ResetLockoutCount = 15"
    }
    
    $newContent | Out-File $tempCfg -Encoding ASCII
    
    secedit /configure /db secedit.sdb /cfg $tempCfg /quiet
    
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue
    Remove-Item "secedit.sdb" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Successfully applied CIS Control 1.2.4" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
