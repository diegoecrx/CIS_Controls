<# 
.SYNOPSIS
  Run all PowerShell scripts in a directory, showing and logging everything they run.

.PARAMETER Path
  Directory containing scripts. Default: current directory.

.PARAMETER Recurse
  Search subdirectories.

.PARAMETER Include
  One or more wildcard patterns to include (default: *.ps1).

.PARAMETER Exclude
  One or more wildcard patterns to exclude.

.PARAMETER OrderBy
  Sort key for execution order. Default: Name. Options: Name, LastWriteTime, CreationTime.

.PARAMETER StopOnError
  Stop immediately if any script fails (nonzero exit code).

.PARAMETER LogDir
  Directory for logs. Default: <Path>\_script-logs\<yyyyMMdd-HHmmss>

.PARAMETER Trace
  Controls child process tracing:
    - None: no Set-PSDebug tracing (default)
    - Commands: echo each command as it runs (Set-PSDebug -Trace 1)
    - CommandsAndVariables: echo commands + variable expansion (Set-PSDebug -Trace 2)

.EXAMPLE
  .\Run-AllScripts.ps1 -Recurse -Trace Commands

.EXAMPLE
  .\Run-AllScripts.ps1 -OrderBy LastWriteTime -StopOnError -Trace CommandsAndVariables
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
  [Parameter(Position=0)]
  [ValidateNotNullOrEmpty()]
  [string]$Path = ".",

  [switch]$Recurse,

  [string[]]$Include = @("*.ps1"),

  [string[]]$Exclude = @(),

  [ValidateSet("Name","LastWriteTime","CreationTime")]
  [string]$OrderBy = "Name",

  [switch]$StopOnError,

  [string]$LogDir,

  [ValidateSet("None","Commands","CommandsAndVariables")]
  [string]$Trace = "None"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-LogDir {
  param([string]$BasePath)
  if (-not $LogDir) {
    $stamp  = Get-Date -Format "yyyyMMdd-HHmmss"
    $LogDir = Join-Path -Path $BasePath -ChildPath ("_script-logs\{0}" -f $stamp)
  }
  if (-not (Test-Path -LiteralPath $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
  }
  return (Resolve-Path -LiteralPath $LogDir).Path
}

function Write-SummaryLog {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  $line | Tee-Object -FilePath (Join-Path $LogDir "summary.log") -Append
}

# Resolve base path
$basePath = (Resolve-Path -LiteralPath $Path).Path
$LogDir   = New-LogDir -BasePath $basePath

Write-SummaryLog "Runner started. BasePath='$basePath' OrderBy=$OrderBy Recurse=$Recurse StopOnError=$StopOnError Trace=$Trace"
Write-SummaryLog "LogDir: $LogDir"

# Gather candidates
$searchParams = @{
  LiteralPath = $basePath
  File        = $true
}
if ($Recurse) { $searchParams.Recurse = $true }

# Build initial file set
$files = @()
foreach ($pattern in $Include) {
  $f = Get-ChildItem @searchParams -Filter $pattern -ErrorAction SilentlyContinue
  if ($f) { $files += $f }
}

# Apply Exclude
if ($Exclude.Count -gt 0) {
  foreach ($pattern in $Exclude) {
    $files = $files | Where-Object { $_.Name -notlike $pattern }
  }
}

# Exclude this runner if it’s inside the same tree
$currentScriptPath = $PSCommandPath
if ($currentScriptPath) {
  $currentResolved = (Resolve-Path -LiteralPath $currentScriptPath).Path
  $files = $files | Where-Object { $_.FullName -ne $currentResolved }
} else {
  $files = $files | Where-Object { $_.Name -notmatch '^Run-AllScripts\.ps1$' }
}

# De-duplicate and sort
$files = $files | Sort-Object -Property $OrderBy, Name -Unique

if (-not $files -or $files.Count -eq 0) {
  Write-SummaryLog "No scripts found matching Include=[$($Include -join ', ')] Exclude=[$($Exclude -join ', ')]. Exiting."
  return
}

Write-SummaryLog ("Found {0} script(s):`n{1}" -f $files.Count, ($files | ForEach-Object { " - " + $_.FullName } | Out-String))

$overallSucceeded = 0
$overallFailed    = 0

foreach ($file in $files) {
  $scriptName   = $file.Name
  $safeBase     = [IO.Path]::GetFileNameWithoutExtension($scriptName)
  $scriptLogDir = Join-Path $LogDir $safeBase
  if (-not (Test-Path -LiteralPath $scriptLogDir)) {
    New-Item -ItemType Directory -Path $scriptLogDir -Force | Out-Null
  }

  $transcriptPath = Join-Path $scriptLogDir "transcript.txt"

  # Build the child command that:
  #  - starts transcript to transcript.txt
  #  - enables Set-PSDebug tracing as requested
  #  - dot-sources the target script so its commands are echoed
  #  - stops transcript and exits with accurate status
  $tracePrelude = switch ($Trace) {
    "Commands"              { "Set-PSDebug -Trace 1" }
    "CommandsAndVariables"  { "Set-PSDebug -Trace 2" }
    default                 { "" }
  }

  $childCommand = @"
`$ErrorActionPreference = 'Stop'
Start-Transcript -Path '$transcriptPath' -Force | Out-Null
try {
  if ('$Trace' -ne 'None') { $tracePrelude }
  . '$($file.FullName)'
  if ('$Trace' -ne 'None') { Set-PSDebug -Trace 0 }
  Stop-Transcript | Out-Null
  exit 0
}
catch {
  try { if ('$Trace' -ne 'None') { Set-PSDebug -Trace 0 } } catch {}
  try { Stop-Transcript | Out-Null } catch {}
  Write-Error $_
  exit 1
}
"@

  $target = $file.FullName
  if ($PSCmdlet.ShouldProcess($target, "Run (showing all commands and logging transcript)")) {
    Write-SummaryLog ("Executing: {0}" -f $target)
    Write-Host "----- BEGIN $scriptName -----"

    # Use invocation (&) so child's output streams to *this* console in real time.
    # We still get a full transcript per script.
    $psiArgs = @(
      "-NoProfile",
      "-ExecutionPolicy","Bypass",
      "-Command", $childCommand
    )

    # Run synchronously and show output live
    & powershell.exe @psiArgs
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
      Write-SummaryLog ("SUCCESS: {0} (ExitCode={1}) Transcript={2}" -f $scriptName, $exitCode, $transcriptPath)
      $overallSucceeded++
    } else {
      Write-SummaryLog ("FAILURE: {0} (ExitCode={1}) Transcript={2}" -f $scriptName, $exitCode, $transcriptPath)
      $overallFailed++
      if ($StopOnError) {
        Write-SummaryLog "StopOnError is set. Aborting further execution."
        Write-Host "----- ABORTING after failure in $scriptName -----"
        break
      }
    }

    Write-Host "----- END $scriptName (ExitCode=$exitCode) -----`n"
  }
}

Write-SummaryLog ("Run complete. Succeeded={0} Failed={1}" -f $overallSucceeded, $overallFailed)

if ($overallFailed -gt 0) { exit 1 } else { exit 0 }
