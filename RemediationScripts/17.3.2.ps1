<#
.SYNOPSIS
    CIS Control 17.3.2 - 17.3.2 (L1) Ensure 'Audit Process Creation' is set to include 'Success'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to include Success :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configurati...

.NOTES
    This script requires administrative privileges.
    It modifies audit policy settings using auditpol.exe.
    
    CIS Control: 17.3.2
    
    AUTOMATION CHANGES:
    - Converted from manual instructions to automatic remediation
    - Uses auditpol.exe to configure audit policy settings
    - Includes user confirmation prompt for safety
    - Verifies settings after application
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\17.3.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CIS Control 17.3.2 - Audit Policy Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will configure the following audit policy:" -ForegroundColor Yellow
Write-Host "  Subcategory: Process Creation" -ForegroundColor White
Write-Host "  Setting: Success" -ForegroundColor White
Write-Host ""
Write-Host "This will enable auditing of process creation events." -ForegroundColor Yellow
Write-Host ""

# Prompt for confirmation
$confirmation = Read-Host "Do you want to apply this audit policy? (Y/N)"
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit 0
}

try {
    Write-Host ""
    Write-Host "Applying audit policy configuration..." -ForegroundColor Cyan
    
    # Configure audit policy using auditpol - only enable Success
    $result = auditpol /set /subcategory:"Process Creation" /success:enable /failure:disable 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully configured audit policy." -ForegroundColor Green
        
        # Verify the setting
        Write-Host ""
        Write-Host "Verifying configuration..." -ForegroundColor Cyan
        $verify = auditpol /get /subcategory:"Process Creation" 2>&1
        Write-Host $verify
        
        Write-Host ""
        Write-Host "CIS Control 17.3.2 applied successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to apply audit policy. Error: $result" -ForegroundColor Red
        exit 1
    }
    
Write-Host "SUCCESS" -ForegroundColor Green
} catch {
    Write-Host "Error applying CIS Control 17.3.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
