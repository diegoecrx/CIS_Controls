<#
.SYNOPSIS
    CIS Control 2.3.1.3 - 2.3.1.3 (L1) Configure 'Accounts: Rename administrator account'

.DESCRIPTION
    To establish the recommended configuration via GP, configure the following UI path:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Accounts: Rename administrator account
 
Impact:
 
You will have to inform users who are authorized to use this acc...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.1.3
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.1.3.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.1.3" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.1.3 (L1) Configure 'Accounts: Rename administrator account'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, configure the following UI path:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Accounts: Rename administrator account
 
Impact:
 
You will have to inform users who are authorized to use this account of the new account name. (The guidance for this setting assumes that the Administrator account was not disabled, which was recommended earlier in this chapter.)

See Also

https://workbench.cisec"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
