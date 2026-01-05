#Requires -RunAsAdministrator
# 17.7.4 (L1) Ensure 'Audit MPSSVC Rule-Level Policy Change' is set to 'Success and Failure'
auditpol /set /subcategory:"{0cce9232-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
