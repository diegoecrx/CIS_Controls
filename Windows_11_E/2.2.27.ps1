#Requires -RunAsAdministrator
# 2.2.27 (L1) Ensure 'Lock pages in memory' is set to 'No One'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeLockMemoryPrivilege =
"@
$tempFile = "$env:TEMP\2.2.27.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.27.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
