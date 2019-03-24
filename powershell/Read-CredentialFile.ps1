<#
.SYNOPSIS
    Read and return a credentials object stored within a json file via Save-Credentials.
.PARAMETER CredentialPath
    Where to read credentials object from.
#>
[CmdletBinding()]
param(
    [string]$CredentialPath = "C:\temp\credentials\defaultCredentials.json"
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

if (-not (Test-Path -Path $CredentialPath -PathType Leaf)) {
    Write-Information "FATAL: credential path '$CredentialPath' does not exist"
    exit 1
}

$credentialJson = Get-Content $CredentialPath
$credentialPsObject = $credentialJson | ConvertFrom-Json

[System.Management.Automation.PSCredential]::new($credentialPsObject.UserName, ($credentialPsObject.Password | ConvertTo-SecureString))
