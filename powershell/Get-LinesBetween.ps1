<#
.SYNOPSIS
    Reads the file at $Path, and outputs the lines between the first line matching $StartRegex (inclusive) and the last line matching $StopRegex (exclusive).
.PARAMETER Path
    Path to the file to be read
.PARAMETER StartRegex
    Regex string to match to start retrieving lines. If omitted, retrieval will start at first line.
.PARAMETER StopRegex
    Regex string to match to stop retrieving lines. If omitted, retrieval will continue until end of file.
.PARAMETER Destination
    Optional path to an output file. If omitted, will output to the pipeline.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$True)][string]$Path,
    [string]$StartRegex,
    [string]$StopRegex,
    [string]$Destination,
    [switch]$NoClobber
)

$targetFile = (Resolve-Path $Path).Path

if ($Destination) {
    $outputFile = Resolve-Path $Destination -ErrorAction SilentlyContinue -ErrorVariable _frperror
    if (-not($outputFile)) {
        $outputFile = $_frperror[0].TargetObject
    }
}

if ($Destination -and (Test-Path $outputFile) -and $NoClobber) {
    throw "The file '$outputFile' already exists"
}

# count lines for verbose output
$i = 0

# sendOutput from start if no $StartRegex provided, otherwise wait until finding it
$sendOutput = -not $StartRegex

# track when we flip from not started to started
$outputStarted = $False
# track shouldProcess approval so we don't request approval per-line
$shouldProcess = $False

if ($sendOutput) {
    Write-Verbose "No StartRegex. Starting output at beginning of file."
}

# ensure strem var is local, only created if we shouldProcess
$stream = $Null

try
{

    foreach ($line in [System.IO.File]::ReadLines($targetFile)) {
        if ((-not $sendOutput) -and ($line -match $StartRegex)) {
            Write-Verbose "Starting output on line: $i"
            $sendOutput = $True
        }
        if ($sendOutput -and $StopRegex -and ($line -match $StopRegex)) {
            Write-Verbose "Ending output on line: $i"
            break;
        }

        # processed the first time that output should be sent
        if ((-not $outputStarted) -and $sendOutput) {
            $outputStarted = $true

            if ($PSCmdlet.ShouldProcess($outputFile, "write output from '$targetFile' starting at line $i")) {
                $shouldProcess = $True

                if ($outputFile) {
                    $stream = [System.IO.StreamWriter]::new($outputFile)
                }
            }
        }

        if ($sendOutput -and $shouldProcess) {
            if ($outputFile) {
                $stream.WriteLine($line)
            } else {
                $line
            }
        }

        if ($i % 10000 -eq 0) {
            Write-Verbose "Reading line: $i"
        }

        $i++
    }
}
finally
{
    if ($stream) {
        $stream.close()
    }
}

Write-Verbose "Complete on line: $i"