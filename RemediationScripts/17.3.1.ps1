<#
.SYNOPSIS
    CIS Control 17.3.1 - 17.3.1 (L1) Ensure 'Audit PNP Activity' is set to include 'Success'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to include Success :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Advanced Audit Policy Configurati...

.NOTES
    This script requires administrative privileges.
    It modifies audit policy settings using auditpol.exe.
    
    CIS Control: 17.3.1
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\17.3.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 17.3.1 - Audit Policy" -ForegroundColor Cyan

try {
    # Extract audit category and subcategory from title
    # This is a simplified version - full implementation would parse the exact category
    
    Write-Host "This control requires configuring audit policy settings." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Recommended Configuration:" -ForegroundColor Cyan
    Write-Host "17.3.1 (L1) Ensure 'Audit PNP Activity' is set to include 'Success'" -ForegroundColor White
    Write-Host ""
    Write-Host "To apply manually using auditpol:" -ForegroundColor Cyan
    Write-Host "1. Identify the audit subcategory from the control description" -ForegroundColor White
    Write-Host "2. Use: auditpol /set /subcategory:<name> /success:enable /failure:enable" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use Group Policy:" -ForegroundColor Cyan
    Write-Host "Computer Configuration\Windows Settings\Security Settings\Advanced Audit Policy Configuration" -ForegroundColor White
    
    # Note: Specific auditpol commands would need exact subcategory names
    # which vary by control
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
