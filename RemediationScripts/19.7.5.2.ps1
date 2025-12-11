<#
.SYNOPSIS
    CIS Control 19.7.5.2 - 19.7.5.2 (L1) Ensure 'Notify antivirus programs when opening attachments' is set

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Attachment Manager\Notify antivirus programs when opening attachments
 
Note: This Group Policy path is provided by the Group Policy tem...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.5.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.5.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.5.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.5.2 (L1) Ensure 'Notify antivirus programs when opening attachments' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled :
 
User Configuration\Policies\Administrative Templates\Windows Components\Attachment Manager\Notify antivirus programs when opening attachments
 
Note: This Group Policy path is provided by the Group Policy template AttachmentManager.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Impact:
 
Windows tells the registered antivirus program(s) to scan the file w"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
