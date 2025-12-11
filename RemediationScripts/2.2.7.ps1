<#
.SYNOPSIS
    CIS Control 2.2.7 - 2.2.7 (L1) Ensure 'Back up files and directories' is set to 'Administrators'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Administrators
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\User Rights Assignmen...

.NOTES
    This script requires administrative privileges.
    User Rights Assignment requires secedit or Group Policy.
    
    CIS Control: 2.2.7
    
    WARNING: This control modifies User Rights Assignment which requires careful
    configuration. The script provides the recommended setting but should be
    reviewed before execution to ensure it matches your environment.
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\2.2.7.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "CIS Control 2.2.7 - User Rights Assignment" -ForegroundColor Cyan
Write-Host ""
Write-Host "This control requires modifying User Rights Assignment." -ForegroundColor Yellow
Write-Host "The recommended setting from CIS:" -ForegroundColor Yellow
Write-Host "2.2.7 (L1) Ensure 'Back up files and directories' is set to 'Administrators'" -ForegroundColor White
Write-Host ""
Write-Host "To apply this manually:" -ForegroundColor Cyan
Write-Host "1. Run: gpedit.msc" -ForegroundColor White
Write-Host "2. Navigate to:" -ForegroundColor White
Write-Host "   Computer Configuration\Windows Settings\Security Settings\Local Policies\User Rights Assignment" -ForegroundColor White
Write-Host "3. Configure the appropriate setting as recommended" -ForegroundColor White
Write-Host ""
Write-Host "Note: Automated configuration of User Rights Assignment via PowerShell" -ForegroundColor Yellow
Write-Host "requires complex secedit manipulation and security principal SID resolution." -ForegroundColor Yellow
Write-Host "For production environments, use Group Policy for consistent application." -ForegroundColor Yellow

# Note: Full automation would require:
# 1. Mapping user names to SIDs
# 2. Exporting current secedit configuration
# 3. Modifying the appropriate privilege assignment section
# 4. Re-importing with secedit
# This is complex and error-prone, so manual GP configuration is recommended
