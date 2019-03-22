<#
.SYNOPSIS
    Performs substitution on a string
.PARAMETER FormatString
    The string to perform substitution on. Substitution will be attempted on substrings matching ${SubstitutionName}
.PARAMETER Substitutions
    HashTable of substitutions to perform. Any key appearing in $FormatString within ${} will be substituted with the corresponding value.
.PARAMETER FailedSubstitution
    What to replace substitutions with if they don't appear in $Substitutions
.PARAMETER BeginInterpolationSequence
    Character sequence indicating the beginning of interpolation block
.PARAMETER EndInterpolationSequence
    Character sequence indicating the end of interpolation block
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][string]$FormatString,
    [Parameter(Mandatory=$True)][HashTable]$Substitutions,
    [string]$FailedSubstitution = "",
    [string]$BeginInterpolationSequence = '${',
    [string]$EndInterpolationSequence = '}'
)
# Future: allow parameterized interpolation tokens
# Future: support function block values in Substitutions


$result = ""
$insideInterpolation = $False
$interpolationKey = ""

function Get-Substitution {
    param([Parameter(Mandatory=$True)][string]$Key)

    if ($Substitutions.ContainsKey($Key)) {
        return $Substitutions[$Key]
    } else {
        return $FailedSubstitution
    }
}

function Match-InterpolationBegin {
    param([Parameter(Mandatory=$True)][int]$index)

    return ($FormatString.Length -gt $index + ($BeginInterpolationSequence.Length -1)) -and
     ($FormatString.Substring($index, $BeginInterpolationSequence.Length) -eq $BeginInterpolationSequence)
}

function Match-InterpolationEnd {
    param([Parameter(Mandatory=$True)][int]$index)

    return ($FormatString.Length -gt $index + ($EndInterpolationSequence.Length -1)) -and
     ($FormatString.Substring($index, $EndInterpolationSequence.Length) -eq $EndInterpolationSequence)
}

for ($i = 0; $i -lt $FormatString.Length; $i++) {
    # we're inside the interpolation section
    if ($insideInterpolation) {
        # end of interpolation section
        if (Match-InterpolationEnd $i) {
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
        if (Match-InterpolationBegin $i) {
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
