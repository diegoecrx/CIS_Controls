<#
.SYNOPSIS
    CIS Control 1.2.1 - 1.2.1 (L1) Ensure 'Account lockout duration' is set to '15'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 15 :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Account Policies\Account Loc...

.NOTES
    This script requires administrative privileges.
    It modifies local security policy settings.
    
    CIS Control: 1.2.1
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\1.2.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 1.2.1..." -ForegroundColor Cyan

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
        if ($line -match "^LockoutDuration\s*=") {
            $newContent += "LockoutDuration = 15"
            $settingFound = $true
        } else {
            $newContent += $line
        }
    }
    
    if (-not $settingFound) {
        $newContent += "LockoutDuration = 15"
    }
    
    $newContent | Out-File $tempCfg -Encoding ASCII
    
    secedit /configure /db secedit.sdb /cfg $tempCfg /quiet
    
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue
    Remove-Item "secedit.sdb" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Successfully applied CIS Control 1.2.1" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
