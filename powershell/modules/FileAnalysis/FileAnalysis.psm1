
Class ManifestFile {
    [string]$name
    [string]$md5
    [string]$size
}

Class ManifestFileError {
    [string]$name
    [string]$errorInfo
    [string]$size
}

function New-FileManifestEntry {
    param(
        [Parameter(Mandatory=$True)][string]$FilePath
    )

    Write-Verbose "New-FileManifestEntry '$FilePath'"
    $item = Get-Item -LiteralPath $FilePath
    $tempFile = New-TemporaryFile
    $hashObj = Get-FileHash -LiteralPath $item.FullName -Algorithm MD5 2>$tempFile

    if ($hashObj) {
        $manifestFile = [ManifestFile]::new()
        $manifestFile.md5 = $hashObj.Hash
    } 
    else {
        # log errors on individual items as warnings, so that manifest can still get generated
        $errorMessage = (Get-Content $tempFile) -join "`n"
        Write-Warning "Failed to get hash for $($FilePath)"
        Write-Warning $errorMessage

        $manifestFile = [ManifestFileError]::new()
        $manifestFile.errorInfo = $errorMessage
    }

    Remove-Item $tempFile

    $manifestFile.name = $item.Name
    $manifestFile.size = $item.Length

    return $manifestFile
}

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
function Get-Md5Manifest {
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string[]]$Targets,

        [ValidateSet("Json", "PowerShell")]
        [string]$Format = "Json",

        [switch]$Recurse
    )

    process {
        foreach ($Target in $Targets) {
            $result = $Null

            if (-not (Test-Path $Target)) {
                throw [System.IO.FileNotFoundException] "Unable to find '$Target'"
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
        }
    }
    

}

<#
.SYNOPSIS
    Reads manifest information from a file or object, then returns a map representing this information (or appends to a pre-existing map). Map entries will be named in relation to the base directory of the manifest, or using BasePath to specify root directory.
.PARAMETER ManifestObj
    A powershell object representing an md5Manifest. Use this option for mapping a manifest that has already been read from file.
.PARAMETER ManifestFilePath
    Path to a md5Manifest stored as a json file.
.PARAMETER ManifestMap
    Use to specify a pre-existing map to add entries to. Use the AppendOnly switch in conjunction to this parameter to avoid returning the resulting (as well as appending to the provided map).
.PARAMETER BasePath
    Specifies path (in '/' notation) to be prepended to file names. E.g. with default BasePath './', all files in the base directory will be prepended with './', all files in subdir 'dirname' will be prepended with './dirname/', and so on.
.PARAMETER AppendOnly
    Specifies that output should only be appended to the provided pre-existing ManifestMap, instead of being returned.
#>
function Read-ManifestMap {
    [CmdletBinding(DefaultParameterSetName='ReadFromFile')]
    param(
        # manifest object read from json to map
        [Parameter(Mandatory=$True, ParameterSetName='ReadFromObject')]
        [object]$ManifestObj,

        [Parameter(Mandatory=$True, ParameterSetName='ReadFromFile')]
        [string]$ManifestFilePath,

        # map to add entries to
        [Parameter(ParameterSetName='ReadFromObject')]
        [Parameter(ParameterSetName='ReadFromFile')]
        $ManifestMap = [ordered]@{},

        # path of parent dirs for manifestObj
        [Parameter(ParameterSetName='ReadFromObject')]
        [Parameter(ParameterSetName='ReadFromFile')]
        [string]$BasePath = './',

        [Parameter(ParameterSetName='ReadFromObject')]
        [Parameter(ParameterSetName='ReadFromFile')]
        [switch]$AppendOnly
    )

    $ErrorActionPreference = 'Stop'


    if ($ManifestFilePath) {
        $ManifestObj = ConvertFrom-Json (Get-Content -Raw $ManifestFilePath)
    }

    if ($manifestObj.files) {
        for ($i = 0; $i -lt $ManifestObj.files.Count; $i++) {
            $curFile = $ManifestObj.files[$i]

            $ManifestMap["${BasePath}$($curFile.name)"] = $curFile
        }
    }

    if ($manifestObj.directories) {
        for ($i = 0; $i -lt $ManifestObj.directories.Count; $i++) {
            $curDir = $ManifestObj.directories[$i]

            if ($curDir.manifest) {
                Read-ManifestMap -ManifestObj $curDir.manifest -ManifestMap $ManifestMap -BasePath "${BasePath}$($curDir.name)/" -AppendOnly
            }
        }
    }

    if (-not $AppendOnly) {
        return $ManifestMap
    }

}

<#
.SYNOPSIS
    Compares two md5 manifests (as generated by Get-Md5Manifest), outputting the differences between them.
.PARAMETER ReferenceFilePath
    Path to the manifest to be evaluated as the reference
.PARAMETER CompareFilePaths
    Path(s) to the manifest(s) to be evaluated for comparison
.PARAMETER CompareFileNameReplace
    Script block to run on the filepath to generate an alternative name for the compared file. By default, file name will be used (without path)
.PARAMETER IncludeMatches
    Set to include files that matched in output.
#>
function Compare-Md5Manifests {
    param(
        [Parameter(Mandatory=$True)]
        [string]$ReferenceFilePath,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string[]]$CompareFilePaths,

        [ScriptBlock]$CompareFileNameReplace = {
            param([string]$filePath)

            return Split-Path -Leaf $filePath
        },

        [switch]$IncludeMatches
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        $referenceMap = Read-ManifestMap -ManifestFilePath $ReferenceFilePath    
    }

    Process {
        foreach($compareFilePath in $CompareFilePaths) {
            $compareMap = Read-ManifestMap -ManifestFilePath $CompareFilePath

            $compareFileAlias = Invoke-Command -ScriptBlock $CompareFileNameReplace -ArgumentList $compareFilePath

            foreach ($curKey in $referenceMap.Keys) {
                Write-Verbose "Examining $curKey"
                $referenceValue = $referenceMap[$curKey]
        
                $compareValue = $compareMap[$curKey]
                Write-Verbose "  Comparing $referenceValue to $compareValue"
        
                if ($compareValue) {
                    if ($compareValue.md5 -eq $referenceValue.md5) {
                        if ($IncludeMatches) {
                            [PSCustomObject]@{
                                File = $curKey
                                CompareResult = 'match'
                                CompareFile = $compareFileAlias
                            }    
                        } else {
                            Write-Verbose "$curKey md5 matched"
                        }
                    } else {
                        [PSCustomObject]@{
                            File = $curKey
                            CompareResult = 'md5 mismatch'
                            CompareFile = $compareFileAlias
                        }
                    }
                    # remove key to indicate key was found
                    $compareMap.Remove($curKey)
                } else {
                    [PSCustomObject]@{
                        File = $curKey
                        CompareResult = 'not found in compare file'
                        CompareFile = $compareFileAlias
                    }
                }
            }
        
            # any remaining keys in right map indicate files that weren't present in the left file
            foreach ($curKey in $compareMap.Keys) {
                [PSCustomObject]@{
                    File = $curKey
                    CompareResult = 'not found in reference file'
                    CompareFile = $compareFileAlias
                }
            }
        }
    }

    

}

Export-ModuleMember -Function Get-Md5Manifest, Compare-Md5Manifests, Read-ManifestMap
