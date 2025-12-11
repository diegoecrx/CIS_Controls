<#
.SYNOPSIS
    CIS Control 2.3.7.2 - 2.3.7.2 (L1) Ensure 'Interactive logon: Don't display last signed-in' is set to 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Interactive logon: Don't display last signed-in
 
Note: In older versions of Microsoft Windows, this setting ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.7.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.7.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.7.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.7.2 (L1) Ensure 'Interactive logon: Don't display last signed-in' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Interactive logon: Don't display last signed-in
 
Note: In older versions of Microsoft Windows, this setting was named
 
Interactive logon: Do not display last user name
 
, but it was renamed starting with Windows 10 Release 1703.
 
Impact:
 
The name of the last user to successfully log on will not be disp"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
