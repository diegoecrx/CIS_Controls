<#
.SYNOPSIS
    CIS Control 19.7.8.2 - 19.7.8.2 (L1) Ensure 'Do not suggest third-party content in Windows spotlight' i

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Do not suggest third-party content in Windows spotlight
 
Note: This Group Policy path may not exist by default. It is pro...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.8.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.8.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.8.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.8.2 (L1) Ensure 'Do not suggest third-party content in Windows spotlight' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Do not suggest third-party content in Windows spotlight
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template CloudContent.admx/adml that is included with the Microsoft Windows 10 Release 1607 & Server 2016 Administrative Templates (or newer).
 
Impact:
 
Windows Spotlight o"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
