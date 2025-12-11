<#
.SYNOPSIS
    CIS Control 19.7.5.1 - 19.7.5.1 (L1) Ensure 'Do not preserve zone information in file attachments' is s

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Attachment Manager\Do not preserve zone information in file attachments
 
Note: This Group Policy path is provided by the Group Policy ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.5.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.5.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.5.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.5.1 (L1) Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Attachment Manager\Do not preserve zone information in file attachments
 
Note: This Group Policy path is provided by the Group Policy template AttachmentManager.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
