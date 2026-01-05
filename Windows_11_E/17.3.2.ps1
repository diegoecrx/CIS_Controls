#Requires -RunAsAdministrator
# 17.3.2 (L1) Ensure 'Audit Process Creation' is set to include 'Success'
auditpol /set /subcategory:"{0cce922b-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
