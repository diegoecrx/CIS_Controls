<#
.SYNOPSIS
    CIS Control 19.7.8.4 - 19.7.8.4 (L2) Ensure 'Turn off all Windows spotlight features' is set to 'Enable

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Turn off all Windows spotlight features
 
Note: This Group Policy path may not exist by default. It is provided by the Gro...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.8.4
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.8.4.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.8.4" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.8.4 (L2) Ensure 'Turn off all Windows spotlight features' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Turn off all Windows spotlight features
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template CloudContent.admx/adml that is included with the Microsoft Windows 10 Release 1607 & Server 2016 Administrative Templates (or newer).
 
Impact:
 
Windows Spotlight on lock screen, W"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
