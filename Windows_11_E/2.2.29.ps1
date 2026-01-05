#Requires -RunAsAdministrator
# 2.2.29 (L2) Ensure 'Log on as a service' is configured
# Note: This should be configured based on your environment needs
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeServiceLogonRight =
"@
$tempFile = "$env:TEMP\2.2.29.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.29.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
