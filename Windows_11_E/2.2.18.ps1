#Requires -RunAsAdministrator
# 2.2.18 (L1) Ensure 'Deny log on as a service' to include 'Guests'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeDenyServiceLogonRight = *S-1-5-32-546
"@
$tempFile = "$env:TEMP\2.2.18.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.18.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
