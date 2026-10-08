<#
.SYNOPSIS
    Antigravity Voice Alert Hook for Supasit.A (พี่ A)
    Plays short audible notifications for agent lifecycle events via Windows SAPI.
    Outputs valid JSON '{}' to stdout to adhere to Antigravity hook contracts.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Event = "Alert",

    [Parameter(Mandatory = $false)]
    [string]$Message = ""
)

$ErrorActionPreference = "SilentlyContinue"


# Determine text to speak
$textToSpeak = if ($Message) { $Message } else { $Event }

# Speak via SAPI.SpVoice
# Flag 0 = SVSFDefault (synchronous), ensuring speech completes before process termination
try {
    $voice = New-Object -ComObject SAPI.SpVoice
    [void]$voice.Speak($textToSpeak, 0)
} catch {}

# Adhere to Antigravity Hook contract (always return valid JSON to stdout)
Write-Output '{}'
exit 0
