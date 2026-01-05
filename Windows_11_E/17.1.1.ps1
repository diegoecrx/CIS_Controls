#Requires -RunAsAdministrator
# 17.1.1 (L1) Ensure 'Audit Credential Validation' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce923f-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
