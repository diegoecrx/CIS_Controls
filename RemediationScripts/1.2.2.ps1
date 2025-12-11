<#
.SYNOPSIS
    CIS Control 1.2.2 - 1.2.2 (L1) Ensure 'Account lockout threshold' is set to '5 or fewer invalid logo

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 5 or fewer invalid login attempt(s), but not 0 :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Ac...

.NOTES
    This script requires administrative privileges.
    It modifies local security policy settings.
    
    CIS Control: 1.2.2
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\1.2.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 1.2.2..." -ForegroundColor Cyan

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
        if ($line -match "^LockoutBadCount\s*=") {
            $newContent += "LockoutBadCount = 5, but not 0"
            $settingFound = $true
        } else {
            $newContent += $line
        }
    }
    
    if (-not $settingFound) {
        $newContent += "LockoutBadCount = 5, but not 0"
    }
    
    $newContent | Out-File $tempCfg -Encoding ASCII
    
    secedit /configure /db secedit.sdb /cfg $tempCfg /quiet
    
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue
    Remove-Item "secedit.sdb" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Successfully applied CIS Control 1.2.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
