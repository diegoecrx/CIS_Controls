#Requires -RunAsAdministrator
# 2.2.31 (L1) Ensure 'Modify an object label' is set to 'No One'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeRelabelPrivilege =
"@
$tempFile = "$env:TEMP\2.2.31.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.31.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
