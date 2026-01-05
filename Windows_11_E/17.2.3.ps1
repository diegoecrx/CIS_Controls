#Requires -RunAsAdministrator
# 17.2.3 (L1) Ensure 'Audit User Account Management' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce923b-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
