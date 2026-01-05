#Requires -RunAsAdministrator
# 2.2.34 (L1) Ensure 'Profile single process' is set to 'Administrators'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeProfileSingleProcessPrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.34.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.34.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
