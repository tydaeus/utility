<#
.DESCRIPTION
    Easy way to display a toast notification to the user, with reasonable defaults. Based on the example toast message at https://www.kjctech.net/4-types-of-notifications-generated-in-powershell/. Consider using the BurntToast PowerShell module for more elaborate control.
.PARAMETER Text
    Text content of the toast message.
.PARAMETER Title
    Title displayed over the toast message.
.PARAMETER IconSource
    Filepath to retrieve icon image from; will use whatever icon is used on the specified file
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][string]$Text,
    [string]$Title,
    [string]$IconSource,

    [ValidateSet("None", "Warning", "Error", "Info")]
    [string]$ToolTipIcon,

    [uint32]$Duration = 10000
)

# The ToastNotification type appears to be a little more dedicated to this purpose, but isn't available, at least not within PowerShell 5.1
Add-Type -AssemblyName System.Windows.Forms
$toastMessage = New-Object System.Windows.Forms.NotifyIcon

# BalloonTipText must be specified or the notification will fail
$toastMessage.BalloonTipText = $Text

if ($Title) {
    $toastMessage.BalloonTipTitle = $Title
}

# balloon.Icon is required
if ($IconSource) {
    $iconSourcePath = $IconSource
} else {
    $iconSourcePath = (Get-Process -id $pid).Path
}

# FUTURE: fallback to default icon if unable to extract
$toastMessage.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconSourcePath)

# BalloonTipIcon set to None by default, which will use balloon.Icon
if ($ToolTipIcon) {
    $IconEnum = &{
        switch ($ToolTipIcon) {
            "Info" { return [System.Windows.Forms.ToolTipIcon]::Info }
            "Warning" { return [System.Windows.Forms.ToolTipIcon]::Warning }
            "Error" { return [System.Windows.Forms.ToolTipIcon]::Error }
            "None" { return [System.Windows.Forms.ToolTipIcon]::None }
            default { return [System.Windows.Forms.ToolTipIcon]::None}
        }
    }
    $toastMessage.BalloonTipIcon = $IconEnum
}

$toastMessage.Visible = $True
$toastMessage.ShowBalloonTip($Duration)
