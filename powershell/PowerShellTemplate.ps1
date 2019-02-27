<#
.SYNOPSIS
    Script Synopsis
.DESCRIPTION
    Script long description
.PARAMETER Param1
    Description of first parameter
#>
# omit and ensure you have no [Parameter] attributes on your parameters to create a "basic" function instead of an "advanced" one. But there's not much reason to do that.
[CmdletBinding()]
param(
    [string]$Param1
    # comma-separated parameters, with attribute qualifiers
)

# exit after first uncaught error
$ErrorActionPreference = "Stop"
# display output from Write-Information, which is the recommended textual feedback cmdlet
$InformationPreference = "Continue"
