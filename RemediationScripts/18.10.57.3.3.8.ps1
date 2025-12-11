<#
.SYNOPSIS
    CIS Control 18.10.57.3.3.8 - 18.10.57.3.3.8 (L2) Ensure 'Restrict clipboard transfer from server to client' i

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Disable clipboard transfers from server to client :
 
Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Device and Resource Redirection\Restri...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 18.10.57.3.3.8
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\18.10.57.3.3.8.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 18.10.57.3.3.8" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 18.10.57.3.3.8 (L2) Ensure 'Restrict clipboard transfer from server to client' is set to 'Enabled: Disable clipboard transfers from server to client'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled: Disable clipboard transfers from server to client :
 
Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Device and Resource Redirection\Restrict clipboard transfer from server to client
 
Note: This Group Policy path is provided by the Group Policy template TerminalServer.admx/adml that is included with the Microsoft Windows 11 Release 23H2"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
