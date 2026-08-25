#Requires -Version 3
#Requires -RunAsAdministrator

# The MIT License (MIT) 
# Copyright (C) Microsoft Corporation. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<#
    Sourced from https://gist.githubusercontent.com/heaths/77fbe0b44496960fab25c2eb0b9e8475/raw/8db3eabcd6488cc61854639a5e6afd6aefaafc27/Unregister-MissingMSIs.ps1

    Modified to increase understanding / readability
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $ProductCode
)

$ErrorActionPreference = 'Stop'

$loc = data {
    ConvertFrom-StringData @'
        Error_Elevation_Required = You must run this script in an elevated command prompt
        Error_64Bit_Required = You must run this in a 64-bit command prompt
        Error_PackageManagement_Required = Please install PackageManagement from http://go.microsoft.com/fwlink/?LinkID=746217
        Process_Remove_Args1 = Remove registration for {0}
        Verbose_Install_MSI = Installing the "MSI" module
        Verbose_Scan_Missing = Scanning for products missing cached packages
        Verbose_Remove_Key_Args1 = Removing registry key {0}
        Verbose_Remove_Value_Args2 = Removing registry value {1} from {0}
        Verbose_Remove_Source_Reg = Removing source registration
        Verbose_Remove_Product_Reg = Removing product registration
        Verbose_Remove_Upgrade_Reg = Removing upgrade registration
        Verbose_Remove_Component_Reg = Removing component registration
        Verbose_Found_Source_Args2 = Cache missing for {0} but found source at {1}
'@
}

# History: checked if running as admin; replaced with Requires -RunAsAdministrator

# If we're running on a 64-bit OS, make sure we're running in a 64-bit process
if ([System.Environment]::Is64BitOperatingSystem) {
    if (![System.Environment]::Is64BitProcess) {
        throw $loc.Error_64Bit_Required
    }
}

function ConvertTo-MsiProductCode {
    <#
    .SYNOPSIS
    Reorders a Windows Installer product GUID to the registry key format used by MSI.

    .DESCRIPTION
    MSI stores product and feature registrations in registry keys using a transformed GUID order.
    This helper normalizes the GUID and reindexes the characters to match the Installer\Products
    and Installer\Features naming convention used by Windows Installer.

    .PARAMETER Guid
    The product GUID to convert.

    .OUTPUTS
    System.String
    Returns the registry-formatted product code.

    .EXAMPLE
    PS> ConvertTo-MsiProductCode '{12345678-1234-1234-1234-123456789ABC}'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Guid
    )

    [int[]] $translation = 7,6,5,4,3,2,1,0,11,10,9,8,15,14,13,12,17,16,19,18,21,20,23,22,25,24,27,26,29,28,31,30


    if (!$Guid) {
        return
    }

    $Guid = [System.Guid]::Parse($Guid).ToString('N').ToUpperInvariant()

    $sb = New-Object System.Text.StringBuilder $translation.Count
    foreach ($i in $translation) {
        $null = $sb.Append($Guid[$i])
    }

    return $sb.ToString()
}

function Test-MsiProductCache {
    <#
    .SYNOPSIS
    Determines whether an MSI product still has a valid cached package source.

    .DESCRIPTION
    Returns true when the product registration already exists or when a package source
    path for the product can still be found. This is used to identify products whose
    cached MSI package is missing and therefore should be unregistered.

    .PARAMETER Product
    The product object returned by Get-MSIProductInfo.

    .OUTPUTS
    System.Boolean
    Returns true when the package is available or the product registration exists.

    .EXAMPLE
    PS> Test-MsiProductCache $msi
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Product
    )

    if ($Product.PSPath -and ($Product | Test-Path)) {
        return $true
    }

    if ($Product.PackageName) {
        $Product | Get-MSISource | ForEach-Object {
            $path = Join-Path $_.Path $Product.PackageName
            try {
                if ($path | Test-Path -ErrorAction Stop) {
                Write-Verbose ($loc.Verbose_Found_Source_Args2 -f $Product.ProductCode, $path)
                    return $true
                }
            }
            # not clear what to do if we can't access the path; may still want to remove, though
            catch {
                Write-Warning "Failed to test path '$path' for product $($Product.PackageName) {$($Product.ProductCode)}: $($_.Exception.Message)"
                return $true
            }
        }
    }

    return $false
}

function Remove-MsiRegistryKey {
    <#
    .SYNOPSIS
    Removes a registry key used by Windows Installer for a product or feature registration.

    .DESCRIPTION
    Deletes the specified registry path when it exists, using the current transaction context
    so the cleanup remains consistent with the rest of the MSI unregistration process.

    .PARAMETER Key
    The registry path to remove.

    .EXAMPLE
    PS> Remove-MsiRegistryKey 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\ABC123'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Key
    )

    if (Test-Path $Key) {
        Write-Verbose ($loc.Verbose_Remove_Key_Args1 -f $Key)
        Remove-Item -Recurse -Force -UseTransaction $Key
    }
}

function Remove-MsiRegistryValue {
    <#
    .SYNOPSIS
    Removes an MSI product or feature value from registry subkeys under a given parent key.

    .DESCRIPTION
    Scans child entries beneath the supplied registry key, removes the matching value when present,
    and deletes the child key itself if it becomes empty after the value removal.

    .PARAMETER Key
    The parent registry key to scan.

    .PARAMETER Name
    The property name to remove from each child entry.

    .EXAMPLE
    PS> Remove-MsiRegistryValue -Key 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes' -Name 'ABC123'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Key,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Name
    )

    if (Test-Path $Key) {
        Get-ChildItem $Key | ForEach-Object {
            $obj = $_ | Get-ItemProperty
            if ($obj.$Name -ne $null) {
                Write-Verbose ($loc.Verbose_Remove_Value_Args2 -f $_.Name, $Name)
                Remove-ItemProperty -Force -UseTransaction -Name $Name -LiteralPath $_.PSPath

                $obj = Get-ItemProperty -UseTransaction -LiteralPath $_.PSPath
                if (!$obj) {
                    Write-Verbose ($loc.Verbose_Remove_Key_Args1 -f $_.Name)
                    Remove-Item -Recurse -Force -UseTransaction -LiteralPath $_.PSPath
                }
            }
        }
    }
}

# if ProductCode is not specified, scan for products with missing cached MSIs
if (!$ProductCode) {
    # Install the MSI module if missing.
    if (!(Get-Module -ListAvailable MSI)) {
        Write-Verbose $loc.Verbose_Install_MSI

        # Make sure PackageManagement is installed (comes with WMF 5.0 / Windows 10).
        if (!(Get-Module -ListAvailable PackageManagement)) {
            throw $loc.Error_PackageManagement_Required
        }

        Install-Module MSI -Scope CurrentUser -SkipPublisherCheck -Force
    }

    Write-Verbose $loc.Verbose_Scan_Missing
    foreach ($msi in (Get-MSIProductInfo -UserContext Machine)) {
        if (!(Test-MsiProductCache -Product $msi)) {
            $ProductCode += $msi.ProductCode
        }
    }
}

foreach ($code in $ProductCode) {
    if ($PSCmdlet.ShouldProcess($msi, $loc.Process_Remove_Args1 -f $code)) {
        $packedProductCode = ConvertTo-MsiProductCode -Guid $code

        Start-Transaction

        Write-Verbose $loc.Verbose_Remove_Source_Reg
        Remove-MsiRegistryKey -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\$packedProductCode"
        Remove-MsiRegistryKey -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\$packedProductCode"

        Write-Verbose $loc.Verbose_Remove_Product_Reg
        Remove-MsiRegistryKey -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$packedProductCode"
        Remove-MsiRegistryKey -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$code"
        Remove-MsiRegistryKey -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$code"

        Write-Verbose $loc.Verbose_Remove_Upgrade_Reg
        Remove-MsiRegistryValue -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes" -Name $packedProductCode

        Write-Verbose $loc.Verbose_Remove_Component_Reg
        Remove-MsiRegistryValue -Key "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -Name $packedProductCode

        Complete-Transaction
    }
}

<#
.SYNOPSIS
Removes Windows Installer product registrtation for missing or specified MSIs

.DESCRIPTION
If Windows Installer product registration is corrupt (exit code 1610) or package
sources are missing (exit code 1603, error message 1714; or exit code 1612),
you can use this script in an elevated PowerShell command shell to clean up the
registration is a transactional manner to avoid making machine state worse.

Please note that this should be a last resort and only for those issues above.
The old msizap.exe program was frought with issues and can make matters worse
if not used properly.

.PARAMETER ProductCode
Optional list of ProductCode to clean up; otherwise, ProductCodes are scanned
from products with missing sources.

.EXAMPLE
PS> Unregister-MissingMSIs.ps1

Removes per-machine product registration for products with missing cached MSIs.

.EXAMPLE
PS> Unregister-MissingMSIs.ps1 '{7B88D6BB-A664-4E5A-AB81-C435C8639A4D}'

Remove per-machine product registration for the specified ProductCode only.
#>