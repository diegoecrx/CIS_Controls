#Requires -RunAsAdministrator
# 17.6.4 (L1) Ensure 'Audit Removable Storage' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9245-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
