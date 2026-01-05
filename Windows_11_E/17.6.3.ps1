#Requires -RunAsAdministrator
# 17.6.3 (L1) Ensure 'Audit Other Object Access Events' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9227-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
