#Requires -RunAsAdministrator
# 2.3.7.5 (L1) Configure 'Interactive logon: Message text for users attempting to log on'
# Note: Customize the message text as needed for your organization
$messageText = "LEGAL NOTICE: Unauthorized access to this system is forbidden and will be prosecuted by law."
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeText" -Value $messageText -Type String -Force
