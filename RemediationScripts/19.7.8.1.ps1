<#
.SYNOPSIS
    CIS Control 19.7.8.1 - 19.7.8.1 (L1) Ensure 'Configure Windows spotlight on lock screen' is set to 'Dis

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Configure Windows spotlight on lock screen
 
Note: This Group Policy path may not exist by default. It is provided by the...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.8.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.8.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.8.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.8.1 (L1) Ensure 'Configure Windows spotlight on lock screen' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Configure Windows spotlight on lock screen
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template CloudContent.admx/adml that is included with the Microsoft Windows 10 Release 1607 & Server 2016 Administrative Templates (or newer).
 
Impact:
 
Windows Spotlight will be turne"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
