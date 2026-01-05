#Requires -RunAsAdministrator
# 2.2.20 (L1) Ensure 'Deny log on through Remote Desktop Services' to include 'Guests, Local account'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeDenyRemoteInteractiveLogonRight = *S-1-5-32-546
"@
$tempFile = "$env:TEMP\2.2.20.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.20.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
