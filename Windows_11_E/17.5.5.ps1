#Requires -RunAsAdministrator
# 17.5.5 (L1) Ensure 'Audit Other Logon/Logoff Events' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce921c-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
