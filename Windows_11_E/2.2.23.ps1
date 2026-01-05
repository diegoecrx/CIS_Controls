#Requires -RunAsAdministrator
# 2.2.23 (L1) Ensure 'Generate security audits' is set to 'LOCAL SERVICE, NETWORK SERVICE'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeAuditPrivilege = *S-1-5-19,*S-1-5-20
"@
$tempFile = "$env:TEMP\2.2.23.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.23.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
