<#
.SYNOPSIS
    CIS Control 18.10.58.2 - 18.10.58.2 (L1) Ensure 'Turn on Basic feed authentication over HTTP' is set to '

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Administrative Templates\Windows Components\RSS Feeds\Turn on Basic feed authentication over HTTP
 
Note: This Group Policy path is provided by the Group Policy template InetRes.admx/a...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 18.10.58.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\18.10.58.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 18.10.58.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 18.10.58.2 (L1) Ensure 'Turn on Basic feed authentication over HTTP' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Administrative Templates\Windows Components\RSS Feeds\Turn on Basic feed authentication over HTTP
 
Note: This Group Policy path is provided by the Group Policy template InetRes.admx/adml that is included with the Microsoft Windows 7 & Server 2008 R2 Administrative Templates (or newer).
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/ben"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
