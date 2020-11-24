<#
    Provides utility functions that can make it a bit easier to perform common tasks in PowerShell
#>


<#
.SYNOPSIS
    Performs substitution on a string
.PARAMETER FormatString
    The string to perform substitution on. Substitution will be attempted on substrings matching ${SubstitutionName}
.PARAMETER Substitutions
    HashTable of substitutions to perform. Any key appearing in $FormatString within ${} will be substituted with the corresponding value.
.PARAMETER SubstitutionFunction
    ScriptBlock defining how to perform substitution. Return value will be used as the substitution.
.PARAMETER FailedSubstitution
    What to replace substitutions with if they don't appear in $Substitutions
.PARAMETER BeginInterpolationSequence
    Character sequence indicating the beginning of interpolation block
.PARAMETER EndInterpolationSequence
    Character sequence indicating the end of interpolation block
#>
function Resolve-Interpolation {
    param(
        [Parameter(Mandatory=$True, ParameterSetName="SubstitutionTable")]
        [Parameter(Mandatory=$True, ParameterSetName="SubstitutionFunction")]
        [string]
        $FormatString,

        [Parameter(Mandatory=$True, ParameterSetName="SubstitutionTable")]
        [HashTable]
        $Substitutions,

        [Parameter(Mandatory=$True, ParameterSetName="SubstitutionFunction")]
        [ScriptBlock]
        $SubstitutionFunction,

        [Parameter(Mandatory=$False, ParameterSetName="SubstitutionTable")]
        [string]$FailedSubstitution = "",

        [Parameter(Mandatory=$False, ParameterSetName="SubstitutionTable")]
        [Parameter(Mandatory=$False, ParameterSetName="SubstitutionFunction")]
        [string]$BeginInterpolationSequence = '${',

        [Parameter(Mandatory=$False, ParameterSetName="SubstitutionTable")]
        [Parameter(Mandatory=$False, ParameterSetName="SubstitutionFunction")]
        [string]$EndInterpolationSequence = '}'
    )

    $result = ""
    $insideInterpolation = $False
    $interpolationKey = ""

    function Get-Substitution {
        param(
            [Parameter(Mandatory=$True)][string]$Key
        )

        if ($Substitutions) {
            if ($Substitutions.ContainsKey($Key)) {
                return $Substitutions[$Key]
            } else {
                return $FailedSubstitution
            }
        }
        elseif ($SubstitutionFunction) {
            return &$SubstitutionFunction $Key
        }
        else {
            Write-Host "ERR: Mandatory parameter omitted. This should never happen."
            exit 1
        }
    }

    function Match-Sequence {
        param(
            [Parameter(Mandatory=$True)][int]$index,
            [Parameter(Mandatory=$True)][string]$Sequence
        )

        return ($FormatString.Length -gt $index + ($Sequence.Length -1)) -and
         ($FormatString.Substring($index, $Sequence.Length) -eq $Sequence)
    }


    for ($i = 0; $i -lt $FormatString.Length; $i++) {
        # we're inside the interpolation section
        if ($insideInterpolation) {
            # end of interpolation section
            if (Match-Sequence $i $EndInterpolationSequence) {
                $insideInterpolation = $False
                $result += Get-Substitution($interpolationKey)
                $interpolationKey = ""
                $i += ($EndInterpolationSequence.Length - 1)
            }
            # continue reading interpolation section
            else {
                $interpolationKey += $FormatString[$i]
            }

        }
        # we're reading regular text
        else {
            # detect interpolation
            if (Match-Sequence $i $BeginInterpolationSequence) {
                $insideInterpolation = $True
                $i += ($BeginInterpolationSequence.Length - 1)
            }
            # continue reading regular text
            else {
                $result += $FormatString[$i]
            }
        }
    }

    return $result
}


<#
.SYNOPSIS
    Convenience function to run ScriptBlock either on the remote target or the current host.
.PARAMETER ScriptBlock
    ScriptBlock to be run.
.PARAMETER Session
    Session to run the ScriptBlock in. Leave empty to run on the local host (this can help with supporting host-agnostic scripting).
.PARAMETER ArgumentList
	List of arguments to provide to the script block during invocation.
.PARAMETER IgnoreErrors
    Set to ignore errors output by the command.
.PARAMETER MergeStreams
    Set to redirect all streams to stdout (&1) - use if the commands in ScriptBlock will generate output on other streams (e.g. stderr) and you want to capture this output.
.PARAMETER NullSpacedOutput
    Set to correct for the UTF-16ish output from some commands by omitting all null characters. Note that this will coerce the output to a string if it isn't already.
#>
function Invoke-RemoteCommand {
    param(
        [ScriptBlock]$ScriptBlock,
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Object[]]$ArgumentList,
        [switch]$IgnoreErrors,
        [switch]$MergeStreams,
        [switch]$NullSpacedOutput
    )

    $parameters = @{
        "ScriptBlock" = $ScriptBlock
    }

    if ($Session) {
        $parameters["Session"] = $Session
    }

    if ($IgnoreErrors) {
        $parameters["ErrorAction"] = "Ignore"
    }

    if ($ArgumentList) {
        $parameters["ArgumentList"] = $ArgumentList
    }

    if ($MergeStreams) {
        $result = Invoke-Command @parameters *>&1
    } else {
        $result = Invoke-Command @parameters
    }

    if ($NullSpacedOutput) {
        #Correct for Riposte commands' strange UTF-16ish output
        return ($result | ForEach-Object { $_ -replace "\0",'' })
    } else {
        return $result
    }
}

<#
.SYNOPSIS
    Returns a string containing declaration and definition for a named function(s).
.PARAMETER FunctionName
    The name of the function to package
.EXAMPLE
    # package function 'Run-MyFunction', load it into a (already-created) remote session, then use it
    $packagedFcn = Get-PackagedFunction 'Run-MyFunction'

    # create the function on a (already-created) remote session
    Invoke-Command -Session $session -ScriptBlock { 
        param($fcn); . ([ScriptBlock]::Create($fcn))
    } -ArgumentList $packagedFcn

    # use the packaged function in the loaded session, passing arg1Value into the session as arg1
    Invoke-Command -Session $session -ScriptBlock { 
        param($arg1); Run-MyFunction $arg1 
    } -ArgumentList $arg1Value
#>
function Get-PackagedFunction {
    param([Parameter(Mandatory=$True, ValueFromPipeline=$True)][string]$FunctionName)

    process {
        if (Test-Path "function:$FunctionName") {
            return "function $FunctionName { $(Get-Content "function:$FunctionName") }"
        } else {
            throw { "No function named '$FunctionName' within scope."}
        }    
    }
}

<#
.SYNOPSIS
    Converts PsCustomObjects into HashTables so that they can be splatted or otherwise processed. Note that this is a shallow conversion, and some properties may not convert properly, so be sure to test.
#>
function Convert-PsCustomObjectToHashTable {
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PsCustomObject]
        $obj
    )

    Process {
        $result = @{}
        $obj.psobject.properties | ForEach-Object {
            $result[$_.Name] = $_.Value
        }

        return $result
    }
}


