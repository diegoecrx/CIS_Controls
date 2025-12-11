<#
.SYNOPSIS
    CIS Control 2.3.7.6 - 2.3.7.6 (L1) Configure 'Interactive logon: Message title for users attempting to

.DESCRIPTION
    To establish the recommended configuration via GP, configure the following UI path to a value that is consistent with the security and operational requirements of your organization:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Interactive logon...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.7.6
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.7.6.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.7.6" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.7.6 (L1) Configure 'Interactive logon: Message title for users attempting to log on'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, configure the following UI path to a value that is consistent with the security and operational requirements of your organization:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Interactive logon: Message title for users attempting to log on
 
Impact:
 
Users will have to acknowledge a dialog box with the configured title before they can log on to the computer.

See Also

https://workbench.ci"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
