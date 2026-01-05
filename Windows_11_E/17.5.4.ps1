#Requires -RunAsAdministrator
# 17.5.4 (L1) Ensure 'Audit Logon' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9215-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
