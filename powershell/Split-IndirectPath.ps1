<#
.SYNOPSIS
    Splits a string containing a path into an array containing the initial indirect part as element 0 and the rest of the path as element 1. Empty strings will be used to represent non-applicable path pieces.
.EXAMPLE
PS> Split-IndirectPath '..\..\foo\bar'
..\..\
foo\bar
PS>

.EXAMPLE
PS> Split-IndirectPath 'foo\bar'

foo\bar
PS>

.EXAMPLE
PS> Split-IndirectPath '..\..\..\'
..\..\..\

PS>
#>
param ([Parameter(Mandatory=$True)][string]$indirectPath)

# null or empty path will be bad if we continue
if ([string]::IsNullOrWhiteSpace($indirectPath)) {
    return @('', '')
}

# trim to first non-whitespace character
$indirectPath -match '[^\s]' | Out-Null
$indirectPath = $indirectPath.Substring($indirectPath.IndexOf($Matches[0]))

# trim leading backslash(es), if present
while ($indirectPath.StartsWith('\')) {
    $indirectPath = $indirectPath.Substring(1)
}

$indirection = ''
$direction = ''

# find where we go from indirection to direct paths
if ($indirectPath -match '[^\\.]') {
    $splitIndex = $indirectPath.IndexOf($Matches[0])
    $indirection = $indirectPath.Substring(0, $splitIndex)
    $direction = $indirectPath.Substring($splitIndex)
}
# we have no non-indirection characters
else {
    $indirection = $indirectPath
}

return @($indirection, $direction)
