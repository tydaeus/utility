<#
.SYNOPSIS
    Returns a custom logger object, initialized based on passed parameters.
.PARAMETER LogDir
    Directory to place any file logging output into
.PARAMETER LogName
    Name for generated log file. This will be prefixed with the current date.
.PARAMETER DisableFileOutput
    Set to disable output to the log file.
.PARAMETER DisableConsoleOutput
    Set to disable log output to the Write-Information stream
.PARAMETER FileLogLevel
    Minimum log message level to be output to file.
.PARAMETER ConsoleLogLevel
    Minimum log message level to be displayed.
#>
[CmdletBinding()]
param(
    [string]$LogDir,
    [string]$LogName,
    [switch]$DisableFileOutput,
    [switch]$DisableConsoleOutput,

    [ValidateSet("Trace", "Debug", "Information", "Warning", "Error", "Critical", "None")]
    [string]$FileLogLevel,

    [ValidateSet("Trace", "Debug", "Information", "Warning", "Error", "Critical", "None")]
    [string]$ConsoleLogLevel,

    [ScriptBlock]$MessageTransform

)

Class Logger {
    [string] $LogDir
    [string] $LogName
    [string] $FileLogLevel
    [string] $ConsoleLogLevel
    [bool]$DisableFileOutput = $false
    [bool]$DisableConsoleOutput = $false

    # default transformation
    [ScriptBlock]$MessageTransform = {
        param($Message, $LogLevel)

        return $Message
    }

    Trace([string]$Message) {
        $this.Log($Message, "Trace")
    }

    Debug([string]$Message) {
        $this.Log($Message, "Debug")
    }

    Info([string]$Message) {
        $this.Log($Message, "Information")
    }

    Information([string]$Message) {
        $this.Log($Message, "Information")
    }

    Warning([string]$Message) {
        $this.Log($Message, "Warning")
    }

    Warn([string]$Message) {
        $this.Log($Message, "Warning")
    }

    Error([string]$Message) {
        $this.Log($Message, "Error")
    }

    Err([string]$Message) {
        $this.Log($Message, "Error")
    }

    Critical([string]$Message) {
        $this.Log($Message, "Critical")
    }

    hidden Log([string]$Message, [string]$LogLevel) {

        $minFileLogLevel = $this::LogLevelToNumberMap[$this.FileLogLevel]
        $minConsoleLogLevel = $this::LogLevelToNumberMap[$this.ConsoleLogLevel]
        $attemptedLogLevel = $this::LogLevelToNumberMap[$LogLevel]

        $Message = &$this.MessageTransform $Message $LogLevel
        $prefix = $this::LogLevelToPrefixMap[$LogLevel]

        if (-not $this.disableConsoleOutput -and ($minConsoleLogLevel -le $attemptedLogLevel)) {

            Write-Information -InformationAction Continue "${prefix}: $Message"
        }

        if (-not $this.disableFileOutput -and ($minFileLogLevel -le $attemptedLogLevel)) {
            $logPath = [System.IO.Path]::Combine($this.LogDir, "$([DateTime]::Now.ToString("yyyyMMdd"))_$($this.LogName)")

            $originalEncoding = $Global:PSDefaultParameterValues['Out-File:Encoding']
            $Global:PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

            Add-Content -Path $logPath -Value "$([DateTime]::Now.ToString("yyyyMMdd-HH:mm:ss")) ${prefix}: $Message"

            $Global:PSDefaultParameterValues['Out-File:Encoding'] = $originalEncoding
        }

    }

    static $LogLevelToNumberMap = @{
        "Trace" = 0
        "Debug" = 1
        "Information" = 2
        "Warning" = 3
        "Error" = 4
        "Critical" = 5
        "None" = 6
    }

    static $LogLevelToPrefixMap = @{
        "Trace" = "TRA"
        "Debug" = "DBG"
        "Information" = "INFO"
        "Warning" = "WARN"
        "Error" = "ERR"
        "Critical" = "CRIT"
        "None" = "NONE"
    }

}

# Perform initialization within function, so that class and function can be extracted to inline logging functionality.
function Define-Logger {
    param(
        [string]$LogDir = "C:\temp",
        [string]$LogName = "log.log",
        [switch]$DisableFileOutput,
        [switch]$DisableConsoleOutput,

        [ValidateSet("Trace", "Debug", "Information", "Warning", "Error", "Critical", "None")]
        [string]$FileLogLevel,

        [ValidateSet("Trace", "Debug", "Information", "Warning", "Error", "Critical", "None")]
        [string]$ConsoleLogLevel,

        [ScriptBlock]$MessageTransform
    )

    $result = [Logger]::new()
    $result.FileLogLevel = $FileLogLevel
    $result.ConsoleLogLevel = $ConsoleLogLevel
    $result.LogDir = $LogDir
    $result.LogName = $LogName
    $result.disableFileOutput = $disableFileOutput
    $result.disableConsoleOutput = $disableConsoleOutput

    if ($MessageTransform) {
        $result.MessageTransform = $MessageTransform
    }

    return $result
}

Define-Logger @PSBoundParameters
