<#
.SYNOPSIS
    Performs substitution on a string
.PARAMETER FormatString
    The string to perform substitution on. Substitution will be attempted on substrings matching ${SubstitutionName}
.PARAMETER Substitutions
    HashTable of substitutions to perform. Any key appearing in $FormatString within ${} will be substituted with the corresponding value.
.PARAMETER FailedSubstitution
    What to replace substitutions with if they don't appear in $Substitutions
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][string]$FormatString,
    [Parameter(Mandatory=$True)][HashTable]$Substitutions,
    [string]$FailedSubstitution = ""
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

for ($i = 0; $i -lt $FormatString.Length; $i++) {
    # we're inside the interpolation section
    if ($insideInterpolation) {
        # end of interpolation section
        if ($FormatString[$i] -eq '}') {
            $insideInterpolation = $False
            $result += Get-Substitution($interpolationKey)
            $interpolationKey = ""
        }
        # continue reading interpolation section
        else {
            $interpolationKey += $FormatString[$i]
        }

    }
    # we're reading regular text
    else {
        # detect interpolation
        if (($FormatString.Length -gt $i + (2 - 1)) -and ($FormatString.Substring($i, 2) -eq '${')) {
            $insideInterpolation = $True
            $i += 1
        }
        # continue reading regular text
        else {
            $result += $FormatString[$i]
        }
    }
}

return $result
