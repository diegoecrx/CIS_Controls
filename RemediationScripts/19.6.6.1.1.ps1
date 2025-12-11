<#
.SYNOPSIS
    CIS Control 19.6.6.1.1 - 19.6.6.1.1 (L2) Ensure 'Turn off Help Experience Improvement Program' is set to 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\System\Internet Communication Management\Internet Communication Settings\Turn off Help Experience Improvement Program
 
Note: This Group Policy path is prov...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.6.6.1.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.6.6.1.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.6.6.1.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.6.6.1.1 (L2) Ensure 'Turn off Help Experience Improvement Program' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\System\Internet Communication Management\Internet Communication Settings\Turn off Help Experience Improvement Program
 
Note: This Group Policy path is provided by the Group Policy template HelpAndSupport.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Impact:
 
Users cannot participate in the Help Experi"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
