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

$result = ""
$formatCharArr = $FormatString.ToCharArray()
$insideInterpolation = $False
$interpolationKey = ""
[char]$curChar = $Null
[char]$nextChar = $Null

function Get-Substitution {
    param([Parameter(Mandatory=$True)][string]$Key)

    if ($Substitutions.ContainsKey($Key)) {
        return $Substitutions[$Key]
    } else {
        return $FailedSubstitution
    }
}

for ($i = 0; $i -lt $formatCharArr.Length; $i++) {
    $curChar = $formatCharArr[$i]
    # this will be $Null when we read past the end of the array
    $nextChar = $formatCharArr[$i + 1]

    # we're inside the interpolation section
    if ($insideInterpolation) {
        # finish interpolation section
        if ($curChar -eq '}') {
            $insideInterpolation = $False
            $result += Get-Substitution($interpolationKey)
            $interpolationKey = ""
        }
        # continue reading interpolation section
        else {
            $interpolationKey += $curChar
        }
    }
    # we're reading regular text
    else {
        # detect interpolation
        if (($curChar -eq '$') -and ($nextChar -eq '{')) {
            $insideInterpolation = $True
            $i++
        }
        # continue reading regular text
        else {
            $result += $curChar
        }
    }
}

return $result
