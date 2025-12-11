# CIS Controls Remediation Scripts

This directory contains PowerShell remediation scripts for failed CIS (Center for Internet Security) controls identified in the Windows 11 Enterprise compliance report.

## Overview

These scripts were automatically generated based on the `Windows11_ComplianceReport.html` file, which contains 429 failed CIS controls for Windows 11 Enterprise. Each script is designed to implement the remediation described in the CIS Benchmark documentation.

## Script Naming Convention

Each script is named according to its CIS control ID. For example:
- `1.1.1.ps1` - Enforce password history
- `18.1.1.1.ps1` - Prevent enabling lock screen camera
- `19.7.46.2.1.ps1` - Prevent Codec Download

## Prerequisites

### General Requirements
- **Administrator Privileges**: All scripts require administrative rights to execute
- **Windows 11 Enterprise**: Scripts are designed for Windows 11 Enterprise edition
- **PowerShell**: Scripts require PowerShell 5.1 or higher
- **Execution Policy**: You may need to adjust the PowerShell execution policy

### Setting Execution Policy (if needed)
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Script Categories

### 1. Password Policy (1.1.x)
Scripts that modify password policy settings using `secedit`.
- Example: `1.1.1.ps1`, `1.1.3.ps1`, `1.1.4.ps1`

### 2. Account Lockout Policy (1.2.x)
Scripts that configure account lockout settings using `secedit`.
- Example: `1.2.1.ps1`, `1.2.2.ps1`, `1.2.4.ps1`

### 3. User Rights Assignment (2.2.x)
Scripts that provide guidance for configuring user rights assignments.
- **Note**: These scripts provide instructions rather than automated configuration due to complexity
- Example: `2.2.2.ps1`, `2.2.5.ps1`

### 4. Security Options (2.3.x)
Scripts that modify security options via registry or Group Policy.
- Example: `2.3.x.ps1` controls

### 5. Audit Policies (17.x)
Scripts that provide guidance for configuring advanced audit policies.
- **Note**: These require `auditpol.exe` or Group Policy configuration
- Example: `17.1.1.ps1`, `17.2.1.ps1`

### 6. Administrative Templates (18.x, 19.x)
Scripts that modify registry settings based on Group Policy administrative templates.
- Example: `18.1.1.1.ps1`, `19.7.46.2.1.ps1`

## Usage

### Running Individual Scripts

1. **Open PowerShell as Administrator**
   ```powershell
   # Right-click PowerShell and select "Run as Administrator"
   ```

2. **Navigate to the RemediationScripts directory**
   ```powershell
   cd "path\to\RemediationScripts"
   ```

3. **Execute a specific script**
   ```powershell
   .\1.1.1.ps1
   ```

### Running Multiple Scripts

To apply multiple controls, you can run scripts in sequence:

```powershell
# Example: Apply all password policy controls
.\1.1.1.ps1
.\1.1.3.ps1
.\1.1.4.ps1
.\1.1.5.ps1
```

Or create a batch execution script:

```powershell
# Apply all controls in section 1.1
Get-ChildItem "1.1.*.ps1" | ForEach-Object { & $_.FullName }
```

## Important Warnings

### ⚠️ Before Running Any Script:

1. **Test in a Non-Production Environment First**
   - Always test scripts in a lab or test environment before production
   - Some settings may impact system functionality or user access

2. **Create System Restore Point**
   ```powershell
   Checkpoint-Computer -Description "Before CIS Remediation" -RestorePointType "MODIFY_SETTINGS"
   ```

3. **Backup Current Configuration**
   - Export current Group Policy settings
   - Document current security settings
   - Take a full system backup

4. **Review Impact Statements**
   - Each control has an "Impact" section in the CIS documentation
   - Some controls may affect legitimate business operations
   - Read the full description in `Windows11_ComplianceReport.html`

5. **User Rights Assignment Scripts (2.2.x)**
   - These require careful configuration to avoid locking out users
   - Review and customize based on your environment
   - Consider using Group Policy for enterprise environments

## Script Output

All automated scripts provide clear SUCCESS/FAIL output:

### Success Output
```
Applying CIS Control X.X.X...
Setting registry value...
Successfully applied CIS Control X.X.X
SUCCESS
```

### Failure Output
```
Applying CIS Control X.X.X...
Error applying CIS Control X.X.X: <error details>
FAIL
```

### Script Categories by Output Type

1. **Automated Scripts (324 total)**
   - **310 scripts**: Full automation with try-catch error handling
     - Print `SUCCESS` on successful remediation
     - Print `FAIL` on errors and exit with code 1
   - **14 scripts**: Informational automation (User Rights Assignment)
     - Display detailed manual instructions
     - Print `SUCCESS` after showing instructions

2. **Manual Configuration Scripts (105 total)**
   - Provide detailed setup instructions
   - Do not print SUCCESS/FAIL (information-only)
   - Primarily for complex Group Policy and user-specific settings

## Script Structure

Each automated script includes:

### Header Comments
```powershell
<#
.SYNOPSIS
    Brief description of the CIS control

.DESCRIPTION
    Detailed description and remediation steps

.NOTES
    Requirements and prerequisites

.EXAMPLE
    Usage examples
#>
```

### Administrator Check
```powershell
#Requires -RunAsAdministrator
```

### Error Handling with SUCCESS/FAIL Output
```powershell
$ErrorActionPreference = "Stop"
try {
    # Remediation logic
    Write-Host "Successfully applied CIS Control X.X.X" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
```

## Limitations

### Manual Configuration Required

Some controls cannot be fully automated and require manual configuration:

1. **User Rights Assignment (2.2.x)**: Requires SID resolution and environment-specific configuration
2. **Audit Policies (17.x)**: May require specific subcategory names via `auditpol`
3. **Complex Administrative Templates**: Some settings require additional context or dependencies

For these controls, the scripts provide:
- Detailed instructions for manual configuration
- Group Policy paths
- Recommended values
- Links to documentation

### Environment-Specific Settings

- Scripts use recommended values from CIS Benchmark
- Your environment may require different values
- Review and customize scripts before deployment

## Testing and Validation

After running remediation scripts:

1. **Check Script Output**
   - Scripts print `SUCCESS` if remediation was applied
   - Scripts print `FAIL` with error details if remediation failed
   - Exit code 0 indicates success, exit code 1 indicates failure

2. **Verify the Settings**
   ```powershell
   # For registry settings
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\..." -Name "SettingName"
   
   # For security policies
   secedit /export /cfg current_policy.txt
   ```

3. **Check Compliance**
   - Re-run the CIS compliance scan
   - Use tools like Microsoft Security Compliance Toolkit
   - Verify with `gpresult /h report.html`

4. **Monitor System Behavior**
   - Check Event Viewer for errors
   - Test user access and functionality
   - Verify business applications work correctly

### Automated Testing Example

```powershell
# Run a script and check its exit code
.\1.2.1.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Remediation successful"
} else {
    Write-Host "Remediation failed"
}

# Or capture output
$output = .\1.2.1.ps1 2>&1
if ($output -match "SUCCESS") {
    Write-Host "Control 1.2.1 remediated successfully"
} elseif ($output -match "FAIL") {
    Write-Host "Control 1.2.1 remediation failed"
    Write-Host $output
}
```

## Troubleshooting

### Common Issues

1. **"Script execution disabled"**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ```

2. **"Access Denied"**
   - Ensure PowerShell is running as Administrator
   - Check if the setting is controlled by domain policy

3. **"Registry path not found"**
   - Scripts create missing registry paths automatically
   - Verify Windows version compatibility

4. **secedit fails**
   - Check for syntax errors in generated configuration
   - Ensure no Group Policy conflicts
   - Review Event Viewer for security policy errors

## Additional Resources

- [CIS Windows 11 Enterprise Benchmark](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [Microsoft Security Baselines](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines)
- [Windows Security Policy Settings Reference](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/)

## Contributing

If you find issues with the scripts or have improvements:
1. Test your changes thoroughly
2. Document the changes clearly
3. Ensure scripts follow the existing structure
4. Include proper error handling

## Disclaimer

These scripts are provided as-is for implementing CIS security controls. While they follow CIS Benchmark recommendations, you should:

- Review each script before execution
- Test in a non-production environment
- Customize for your specific requirements
- Understand the impact of each control
- Maintain backups and recovery procedures

The scripts are automatically generated and may require adjustments for your specific environment.

## Version Information

- **Generated From**: Windows11_ComplianceReport.html
- **CIS Benchmark Version**: 4.0.0
- **Target OS**: Windows 11 Enterprise
- **Total Scripts**: 429
  - Automated with SUCCESS/FAIL: 324 scripts
  - Manual configuration: 105 scripts
- **Date Last Updated**: December 2024

## License

These scripts are provided for implementing security controls based on CIS Benchmarks. Please review the CIS Benchmarks license and your organization's policies before use.
