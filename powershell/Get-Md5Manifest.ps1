<#
.SYNOPSIS
    Creates a manifest describing a file or the contents of a directory based on file names, sizes, and md5 hashes
.PARAMETER Target
    Target to generate a manifest for. If a file, will provide a manifest describing that file. If a directory, will provide a manifest describing the contents of the directory.
.PARAMETER Format
    Format of output.
.PARAMETER Recurse
    Whether to create manifests of contained directories recursively.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$Target,

    [ValidateSet("Json", "PowerShell")]
    [string]$Format = "Json",

    [switch]$Recurse
)

Class ManifestFile {
    [string]$name
    [string]$md5
    [string]$size
}

function New-FileManifestEntry {
    param(
        [Parameter(Mandatory=$True)][string]$FilePath
    )

    $item = Get-Item $FilePath

    $manifestFile = [ManifestFile]::new()

    $manifestFile.name = $item.Name
    $manifestFile.size = $item.Length
    $manifestFile.md5 = (Get-FileHash $item.FullName -Algorithm MD5).Hash

    return $manifestFile
}

$result = $Null

function New-FileManifest {
    param(
        [Parameter(Mandatory=$True)][string]$TargetFile
    )

    $manifest = [PSCustomObject][ordered]@{
        files = [System.Collections.ArrayList]::new()
        directories = [System.Collections.ArrayList]::new()
    }

    Get-ChildItem $TargetFile | ForEach-Object {
        if (Test-Path $_.FullName -PathType "Container") {
            $dirEntry = $Null
            if ($Recurse) {
                $dirEntry = [PsCustomObject][ordered]@{
                    name = $_.Name
                    manifest = New-FileManifest $_.FullName
                }
            } else {
                $dirEntry = [PSCustomObject][ordered]@{
                    name = $_.Name
                }
            }
            $manifest.directories.Add($dirEntry) | Out-Null
        } else {
            $manifest.files.Add((New-FileManifestEntry $_.FullName)) | Out-Null
        }
    }

    if ($manifest.files.Count -eq 0) {
        $manifest.files = $Null
    }

    if ($manifest.directories.Count -eq 0) {
        $manifest.directories = $Null
    }

    return $manifest
}

if (Test-Path $Target -PathType 'Leaf') {
    $result = New-FileManifestEntry $Target
} else {
    $result = New-FileManifest $Target
}

if ($Format -eq "PowerShell") {
    return $result
} elseif ($Format -eq "Json") {
    return $result | ConvertTo-Json -Depth 100
}
