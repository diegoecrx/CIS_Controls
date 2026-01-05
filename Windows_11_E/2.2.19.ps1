#Requires -RunAsAdministrator
# 2.2.19 (L1) Ensure 'Deny log on locally' to include 'Guests'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeDenyInteractiveLogonRight = *S-1-5-32-546
"@
$tempFile = "$env:TEMP\2.2.19.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.19.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
