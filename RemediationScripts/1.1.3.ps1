<#
.SYNOPSIS
    CIS Control 1.1.3 - 1.1.3 (L1) Ensure 'Minimum password age' is set to '1'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 1 :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Account Policies\Password Policy...

.NOTES
    This script requires administrative privileges.
    It modifies local security policy settings.
    
    CIS Control: 1.1.3
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\1.1.3.ps1
#>

#Requires -RunAsAdministrator

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 1.1.3..." -ForegroundColor Cyan

try {
    # Export current security policy
    $tempFile = [System.IO.Path]::GetTempFileName()
    $tempCfg = [System.IO.Path]::GetTempFileName()
    
    Write-Host "Exporting current security policy..."
    secedit /export /cfg $tempFile /quiet
    
    # Read the policy file
    $policyContent = Get-Content $tempFile
    
    # Update the setting
    $newContent = @()
    $settingFound = $false
    
    foreach ($line in $policyContent) {
        if ($line -match "^MinimumPasswordAge\s*=") {
            $newContent += "MinimumPasswordAge = 1"
            $settingFound = $true
            Write-Host "Updated MinimumPasswordAge to 1"
        } else {
            $newContent += $line
        }
    }
    
    # If setting not found, add it
    if (-not $settingFound) {
        # Find the right section
        $inSection = $false
        $sectionAdded = $false
        $newContent = @()
        foreach ($line in $policyContent) {
            $newContent += $line
            if ($line -match "\[System Access\]") {
                $inSection = $true
            } elseif ($inSection -and -not $sectionAdded) {
                if ($line -match "^\[") {
                    $newContent[-1] = "MinimumPasswordAge = 1"
                    $newContent += $line
                    $sectionAdded = $true
                    $inSection = $false
                }
            }
        }
        if (-not $sectionAdded) {
            $newContent += "MinimumPasswordAge = 1"
        }
    }
    
    # Write the updated policy
    $newContent | Out-File $tempCfg -Encoding ASCII
    
    # Import the updated policy
    Write-Host "Importing updated security policy..."
    secedit /configure /db secedit.sdb /cfg $tempCfg /quiet
    
    # Clean up
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue
    Remove-Item "secedit.sdb" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Successfully applied CIS Control 1.1.3" -ForegroundColor Green
    
} catch {
    Write-Host "Error applying CIS Control 1.1.3: $_" -ForegroundColor Red
    exit 1
}
