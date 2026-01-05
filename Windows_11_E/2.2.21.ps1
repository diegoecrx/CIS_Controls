#Requires -RunAsAdministrator
# 2.2.21 (L1) Ensure 'Enable computer and user accounts to be trusted for delegation' is set to 'No One'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeEnableDelegationPrivilege =
"@
$tempFile = "$env:TEMP\2.2.21.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.21.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
