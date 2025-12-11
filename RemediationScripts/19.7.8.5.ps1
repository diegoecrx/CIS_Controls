<#
.SYNOPSIS
    CIS Control 19.7.8.5 - 19.7.8.5 (L1) Ensure 'Turn off Spotlight collection on Desktop' is set to 'Enabl

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Turn off Spotlight collection on Desktop
 
Note: This Group Policy path may not exist by default. It is provided by the Gr...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.8.5
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.8.5.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.8.5" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.8.5 (L1) Ensure 'Turn off Spotlight collection on Desktop' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Cloud Content\Turn off Spotlight collection on Desktop
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template CloudContent.admx/adml that is included with the Microsoft Windows 11 Release 21H2 Administrative Templates (or newer).
 
Impact:
 
The Spotlight collection feature will not be ava"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
