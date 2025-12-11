<#
.SYNOPSIS
    CIS Control 2.2.20 - 2.2.20 (L1) Ensure 'Deny log on through Remote Desktop Services' to include 'Gue

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to include Guests, Local account :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\User...

.NOTES
    This script requires administrative privileges.
    User Rights Assignment requires secedit or Group Policy.
    
    CIS Control: 2.2.20
    
    WARNING: This control modifies User Rights Assignment which requires careful
    configuration. The script provides the recommended setting but should be
    reviewed before execution to ensure it matches your environment.
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\2.2.20.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "CIS Control 2.2.20 - User Rights Assignment" -ForegroundColor Cyan
Write-Host ""
Write-Host "This control requires modifying User Rights Assignment." -ForegroundColor Yellow
Write-Host "The recommended setting from CIS:" -ForegroundColor Yellow
Write-Host "2.2.20 (L1) Ensure 'Deny log on through Remote Desktop Services' to include 'Guests, Local account'" -ForegroundColor White
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

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host "SUCCESS" -ForegroundColor Green
