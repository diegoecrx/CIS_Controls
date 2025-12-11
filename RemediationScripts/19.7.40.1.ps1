<#
.SYNOPSIS
    CIS Control 19.7.40.1 - 19.7.40.1 (L1) Ensure 'Turn off Windows Copilot' is set to 'Enabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Windows Copilot\Turn off Windows Copilot
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy tem...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.40.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.40.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.40.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.40.1 (L1) Ensure 'Turn off Windows Copilot' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Windows Copilot\Turn off Windows Copilot
 
Note: This Group Policy path may not exist by default. It is provided by the Group Policy template WindowsCopilot.admx/adml that is included with the Microsoft Windows 11 Release 23H2 Administrative Templates (or newer).
 
Impact:
 
Users will not be able to use Windows Copilot and its icon w"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
