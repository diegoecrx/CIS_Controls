#Requires -RunAsAdministrator
# 2.2.28 (L2) Ensure 'Log on as a batch job' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeBatchLogonRight = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.28.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.28.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
