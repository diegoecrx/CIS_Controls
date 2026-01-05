#Requires -RunAsAdministrator
# 2.3.7.6 (L1) Configure 'Interactive logon: Message title for users attempting to log on'
# Note: Customize the message title as needed for your organization
$messageTitle = "ATTENTION"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeCaption" -Value $messageTitle -Type String -Force
