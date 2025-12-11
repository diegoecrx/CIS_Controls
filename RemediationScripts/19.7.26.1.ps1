<#
.SYNOPSIS
    CIS Control 19.7.26.1 - 19.7.26.1 (L1) Ensure 'Prevent users from sharing files within their profile.' i

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\Windows Components\Network Sharing\Prevent users from sharing files within their profile.
 
Note: This Group Policy path is provided by the Group Policy tem...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.26.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.26.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.26.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.26.1 (L1) Ensure 'Prevent users from sharing files within their profile.' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\Windows Components\Network Sharing\Prevent users from sharing files within their profile.
 
Note: This Group Policy path is provided by the Group Policy template Sharing.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Impact:
 
Users cannot share files within their profile using the sharing wizard. Also, "
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
