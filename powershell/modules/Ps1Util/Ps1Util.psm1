<#
    Provides utility functions that can make it a bit easier to perform common tasks in PowerShell
#>

<#
    Reads the current environment variable values from the registry and updates them accordingly. Useful for ensuring that the PowerShell session reflects changes made by child processes (e.g. installers).
#>
function Update-Environment {
    $registryKeyNames = @(
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        'HKCU:\Environment'
    )

    foreach ($registryKeyName in $registryKeyNames) {
        $registryKey = Get-Item $registryKeyName
        $valueNames = $registryKey.GetValueNames()
        foreach ($valueName in $valueNames) {
            $value = $registryKey.GetValue($valueName)
            Set-Item -Path "Env:$valueName" -Value $value
        }
    }

    # Update PATH environment variable
	$machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
	$userPath = [System.Environment]::GetEnvironmentVariable("Path","User")
    $env:Path = "$machinePath;$userPath"
}


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

    function Test-Sequence {
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
            if (Test-Sequence $i $EndInterpolationSequence) {
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
            if (Test-Sequence $i $BeginInterpolationSequence) {
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
.PARAMETER FunctionNames
    Array of names functions to package
.EXAMPLE
    # package function 'Run-MyFunction'
    $packagedFcn = Get-PackagedFunction 'Run-MyFunction'

    # create the function on a (already-created) remote session
    Invoke-Command -Session $session -ScriptBlock { 
        param($fcn); . ([ScriptBlock]::Create($fcn))
    } -ArgumentList $packagedFcn

    # use the packaged function in the loaded session, passing arg1Value into the session as arg1
    Invoke-Command -Session $session -ScriptBlock { 
        param($arg1)
        Run-MyFunction $arg1 
    } -ArgumentList $arg1Value
.EXAMPLE
    # package multiple functions
    $packagedFcns = Get-PackagedFunction 'Run-MyFunction','Get-MyData'

    # create the functions on a (already-created) remote session
    Invoke-Command -Session $session -ScriptBlock { 
        param($fcn)
        . ([ScriptBlock]::Create($fcn))
    } -ArgumentList $packagedFcns, $Null
    # Note the null argument; this forces PS1 to treat $packagedFcns as a single arg

    # Use the packaged functions in the loaded session
    Invoke-Command -Session $session -ScriptBlock { 
        param($arg1)
        Run-MyFunction $arg1 | Get-MyData
    } -ArgumentList $arg1Value
#>
function Get-PackagedFunction {
    param([Parameter(Mandatory=$True, ValueFromPipeline=$True)][string[]]$FunctionNames)

    process {
        foreach($functionName in $FunctionNames) {
            if (Test-Path "function:$FunctionName") {
                <#pipe output#> "function $FunctionName { $(Get-Content "function:$FunctionName") }"
            } else {
                throw { "No function named '$FunctionName' within scope."}
            }
        }
    }
}

<#
.SYNOPSIS
    Creates each of the functions within PackagedFunctions within Session.
#>
function Export-PackagedFunction {
    param(
        [Parameter(Mandatory=$True)][string[]]$PackagedFunctions,
        [Parameter(Mandatory=$True)]$Session
    )

    Invoke-Command -Session $Session -ScriptBlock { 
        param($PackagedFunctions)
        . ([ScriptBlock]::Create($PackagedFunctions))
    } -ArgumentList $PackagedFunctions, $Null
}

<#
.SYNOPSIS
    Returns whether the specified process is 32bit (as detected by use of wow64.dll). Note: no process will be detected as 32bit if run on a 32bit system.
#>
function Test-IfProcess32Bit {
    param(
        [Parameter(Mandatory=$True, ParameterSetName='ProcessSpecified')]
        [System.Diagnostics.Process]
        $Process,

        [Parameter(Mandatory=$True, ParameterSetName='ProcessNameSpecified')]
        [string]
        $ProcessName
    )

    if ($ProcessName) {
        $Process = Get-Process -Name $ProcessName
    }

    if (-not $Process) {
        throw 'Process not found'
    }

    $processModules = $process.modules

    foreach ($module in $processModules) {
        if ($module.ModuleName -eq 'wow64.dll') {
            return $True
        }
    }

    return $False
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

<#
.SYNOPSIS
    Converts a hashTable of query parameters into a URI query string to include in an API request.
.PARAMETER QueryParams
    HashTable providing key value pairs to convert into URI query string
#>
function New-QueryString {
    param(
        [Parameter(Mandatory)]
        [HashTable]
        $QueryParams
    )

    $kvArrList = [System.Collections.ArrayList]::new()

    # convert hashtable to array
    foreach($key in $QueryParams.Keys) {
        $kvArrList.Add("$([uri]::EscapeDataString($Key))=$([uri]::EscapeDataString($QueryParams[$key]))") | Out-Null
    }

    $result = "?"

    for ($i = 0; $i -lt $kvArrList.Count; $i++) {
        $result += $kvArrList[$i]

        if ($i -lt ($kvArrList.Count - 1)) {
            $result += "&"
        }
    }

    return $result
}

<#
.SYNOPSIS
    Invokes a RESTful get request.
.PARAMETER BaseUri
    Base portion of the URI to send the request to (e.g. 'https://www.somewhere.com/)
.PARAMETER ApiUri
    API-specific portion of the URI to send the request to (e.g. 'api/interesting_objects/')
.PARAMETER QueryParams
    Key-value query parameters to add at the end of the URI
.PARAMETER WebSession
    An open WebSession to run the request in
.PARAMETER Credential
    Credentials to use to start connection
.PARAMETER Outfile
    Filepath to write output to

#>
function Invoke-GetRequest {
    param(
        [Parameter(Mandatory)][string]$BaseUri,
        [string]$ApiUri,
        [HashTable]$QueryParams,
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
        [pscredential]$Credential,
        [string]$Outfile
    )
    $ErrorActionPreference = 'Stop'

    $queryUri = $BaseUri

    if ($ApiUri) {
        $queryUri += $ApiUri
    }

    if ($QueryParams) {
        $queryString = New-QueryString $QueryParams
        $queryUri += $queryString
    }

    $requestParams = @{
        'Uri' = $queryUri
        'UseBasicParsing' = $True
    }

    # populate parameters that get passed directly to Invoke-WebRequest
    @('WebSession', 'Credential', 'Outfile') | ForEach-Object {
        $value = (Get-Variable $_ -ErrorAction 'SilentlyContinue').Value

        if ($value) {
            $requestParams[$_] = $value
        }
    }

    Invoke-WebRequest @requestParams | Write-Output
}

<#
.SYNOPSIS
    Displays a dialog box with custom button options. Returns the index of the clicked button.
.PARAMETER Buttons
    The list of button names. Names will be used from left to right. The return value will be the index of the clicked button.
.PARAMETER Message
    Message to display in the dialog box.
.PARAMETER Title
    Title to display on the dialog box.
#>
function Show-CustomDialog {
    param (
        [Parameter(Mandatory=$True)][string[]]$Buttons,
        [string]$Message = "Please choose one of the following:",
        [string]$Title = ""
    )

    # there are only 7 DialogResult options that result in the dialog being closed
    if ($Buttons.Count -gt 7) {
        throw "Too many buttons specified; at most 7 can be specified."
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $BUTTON_PADDING = 7
    $buttonSize = [System.Drawing.Size]::new(75, 23)
    $windowSize = [System.Drawing.Size]::new(
        [math]::Max(300, (($Buttons.Count * ($buttonSize.Width + $BUTTON_PADDING)) + ($BUTTON_PADDING * 2))),
        100
    )

    $BUTTON_Y = $windowSize.Height - $BUTTON_PADDING - $buttonSize.Height

    $form = New-Object System.Windows.Forms.Form

    $form.ClientSize = $windowSize
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.TopMost = $True
    $form.Text = $Title
    $form.ControlBox = $False
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $label = New-Object System.Windows.Forms.Label
    $label.Location = [System.Drawing.Point]::new(10,10)
    $label.Size = [System.Drawing.Size]::new(
        ($windowSize.Width - 20),
        ($windowSize.Height - (10 + ($BUTTON_PADDING * 2) + $buttonSize.Height))
    )
    $label.Text = $Message
    $form.Controls.Add($label)
    
    $buttonStartX = $windowSize.Width - ((($buttonSize.Width + $BUTTON_PADDING) * $Buttons.Count) + $BUTTON_PADDING)

    for ($i = 0; $i -lt $Buttons.Count; $i++) {
        $button = [System.Windows.Forms.Button]::new()
        $button.Size = $buttonSize
        $button.UseVisualStyleBackColor = $True
        $button.Text = $Buttons[$i]
        $button.DialogResult = 1 + $i
        $button.Location = [System.Drawing.Point]::new($buttonStartX + 
            $BUTTON_PADDING + (($button.Size.Width + $BUTTON_PADDING)* $i), $BUTTON_Y
        )

        $form.Controls.Add($button)
    }

    # Using show dialog sets the form so it automatically closes when a button is pressed with a DialogResult other than "None".
    $response = $form.ShowDialog()

    return ($response.value__ - 1)
}

<#
.SYNOPSIS
    Displays a yes/no GUI prompt dialog box, and returns 'Yes' or 'No' based on user response.
.PARAMETER Text
    The text prompt to be displayed.
.PARAMETER Title
    The title of the displayed dialog.
#>
function Show-YesNoDialog {
    param(
        [Parameter(Mandatory=$True)][string]$Text,
        [string]$Title
    )

    $wshell = New-Object -ComObject Wscript.Shell
    $buttonClicked = $wshell.Popup($Text, 0, $Title, 0x4)

    $response = $Null

    switch($buttonClicked) {
        6 { $response = 'Yes' }
        7 { $response = 'No' }
        # I don't think this can happen, but let's make it obvious and friendly
        default { throw "Invalid YesNo dialog response constant: $_" }
    }

    return $response
}