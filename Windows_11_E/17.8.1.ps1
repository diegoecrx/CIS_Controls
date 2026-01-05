#Requires -RunAsAdministrator
# 17.8.1 (L1) Ensure 'Audit Sensitive Privilege Use' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9228-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
