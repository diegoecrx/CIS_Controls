<#
.SYNOPSIS
    CIS Control 18.10.57.3.3.1 - 18.10.57.3.3.1 (L2) Ensure 'Allow UI Automation redirection' is set to 'Disabled

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Device and Resource Redirection\Allow UI Automation redirection
 
Note: This Group Polic...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 18.10.57.3.3.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\18.10.57.3.3.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 18.10.57.3.3.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 18.10.57.3.3.1 (L2) Ensure 'Allow UI Automation redirection' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Device and Resource Redirection\Allow UI Automation redirection
 
Note: This Group Policy path is provided by the Group Policy template TerminalServer.admx/adml that is included with the Microsoft Windows 10 Release 21H2 Administrative Templates (or newer).
 
Impact:
 
UI Automation clie"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
