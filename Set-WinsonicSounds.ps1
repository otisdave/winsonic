<#
.SYNOPSIS
    Applies the Winsonic custom WAV sounds to Windows device connect/disconnect events.

.DESCRIPTION
    Copies the .wav files from this repo's sounds/ folder to a local sounds directory
    and points the Windows sound scheme registry entries (HKCU\AppEvents\Schemes\Apps\.Default)
    to them. Use -Restore to revert to Windows defaults instead.

.PARAMETER Restore
    Clears the custom sound assignment (restores Windows default / silent) instead of applying it.

.PARAMETER DestinationFolder
    Where to copy the .wav files on this machine. Defaults to
    "$env:LOCALAPPDATA\Winsonic".

.EXAMPLE
    .\Set-WinsonicSounds.ps1

.EXAMPLE
    .\Set-WinsonicSounds.ps1 -Restore
#>
[CmdletBinding()]
param(
    [switch]$Restore,
    [string]$DestinationFolder = "$env:LOCALAPPDATA\Winsonic"
)

$ErrorActionPreference = 'Stop'

# Maps event folder name (registry) => source .wav file name (repo)
$EventMap = @{
    'DeviceConnect'    = 'DeviceConnect.wav'
    'DeviceDisconnect' = 'DeviceDisconnect.wav'
}

function Set-EventSound {
    param(
        [string]$EventName,
        [string]$WavPath
    )
    $regPath = "HKCU:\AppEvents\Schemes\Apps\.Default\$EventName\.Current"
    if (-not (Test-Path $regPath)) {
        Write-Warning "Registry key not found for event '$EventName' ($regPath) - skipping."
        return
    }
    Set-ItemProperty -Path $regPath -Name '(Default)' -Value $WavPath
    Write-Output "$EventName => $WavPath"
}

if ($Restore) {
    foreach ($eventName in $EventMap.Keys) {
        Set-EventSound -EventName $eventName -WavPath ''
    }
    Write-Output "Restored default (silent) sounds for: $($EventMap.Keys -join ', ')"
    return
}

$repoSoundsFolder = Join-Path $PSScriptRoot 'sounds'

New-Item -ItemType Directory -Force -Path $DestinationFolder | Out-Null

foreach ($eventName in $EventMap.Keys) {
    $sourceWav = Join-Path $repoSoundsFolder $EventMap[$eventName]
    if (-not (Test-Path $sourceWav)) {
        Write-Warning "Source file not found: $sourceWav - skipping $eventName."
        continue
    }
    $destWav = Join-Path $DestinationFolder $EventMap[$eventName]
    Copy-Item -Path $sourceWav -Destination $destWav -Force
    Set-EventSound -EventName $eventName -WavPath $destWav
}

Write-Output "`nDone. Sounds copied to: $DestinationFolder"
Write-Output "Test them from Settings > System > Sound > More sound settings > Sounds tab."
