<#
.SYNOPSIS
    Updates a file's last modified timestamp. Creates the file if it doesn't exist. Equivalent to Linux "Touch" utility.
.PARAMETER FilePath
    Path to the file to touch.
#>
param(
    [Parameter(Mandatory=$True)][string]$FilePath
)

$ErrorActionPreference = "Stop"

# create the file if it doesn't exist
if (-not (Test-Path $FilePath)) {
    New-Item -ItemType File $FilePath
}
# otherwise update its last written time
else {
    (gci $FilePath).LastWriteTime = Get-Date
}
