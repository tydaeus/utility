<#
.SYNOPSIS
    Collects user credentials and stores them securely to hard drive as a json file.
.PARAMETER CredentialPath
    Where to store collected credentials to.
#>
[CmdletBinding()]
param(
    [string]$CredentialPath = "C:\temp\credentials\defaultCredentials.json"
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

if (-not (Test-Path -Path $CredentialPath -IsValid)) {
    Write-Information "FATAL: invalid credential path"
    exit 1
}

$CredentialDir = [System.IO.Path]::GetDirectoryName($CredentialPath)

md $CredentialDir -Force | Out-Null

if (-not (Test-Path -Path $CredentialDir -PathType Container)) {
    Write-Information "FATAL: unable to access credential dir"
    exit 1
}

$credential = Get-Credential -Message "Enter Credentials to Store"

$credentialMap = @{
    UserName = $credential.UserName
    Password = $credential.Password | ConvertFrom-SecureString
}

$credentialJson = $credentialMap | ConvertTo-Json

Set-Content $CredentialPath $credentialJson

Write-Information "Credentials stored to $CredentialPath."
