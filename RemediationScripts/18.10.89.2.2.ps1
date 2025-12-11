<#
.SYNOPSIS
    CIS Control 18.10.89.2.2 - 18.10.89.2.2 (L2) Ensure 'Allow remote server management through WinRM' is set t

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled:
 
Computer Configuration\Administrative Templates\Windows Components\Windows Remote Management (WinRM)\WinRM Service\Allow remote server management through WinRM
 
Note: This Group Policy path is provided by th...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 18.10.89.2.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\18.10.89.2.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 18.10.89.2.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 18.10.89.2.2 (L2) Ensure 'Allow remote server management through WinRM' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled:
 
Computer Configuration\Administrative Templates\Windows Components\Windows Remote Management (WinRM)\WinRM Service\Allow remote server management through WinRM
 
Note: This Group Policy path is provided by the Group Policy template WindowsRemoteManagement.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Note #2: In older Microsoft Windows Administrative Tem"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
