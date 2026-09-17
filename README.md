# Winsonic

Custom Windows notification sounds (WAV overrides) for device connect/disconnect events, with a script to re-apply them on any machine.

## What's here

- [`sounds/DeviceConnect.wav`](sounds/DeviceConnect.wav) — plays when a device (e.g. USB drive) is connected
- [`sounds/DeviceDisconnect.wav`](sounds/DeviceDisconnect.wav) — plays when a device is disconnected
- [`Set-WinsonicSounds.ps1`](Set-WinsonicSounds.ps1) — applies (or restores) these sounds via the registry

## Usage

Clone the repo, then from a PowerShell prompt in the repo folder:

```powershell
.\Set-WinsonicSounds.ps1
```

This copies the `.wav` files to `%LOCALAPPDATA%\Winsonic` and points the Windows sound scheme
(`HKCU\AppEvents\Schemes\Apps\.Default\...`) at them.

To revert to the Windows default (silent):

```powershell
.\Set-WinsonicSounds.ps1 -Restore
```

## Notes

- No admin rights required — everything is under `HKCU` (current user).
- Test changes in **Settings > System > Sound > More sound settings > Sounds tab**.
- To add more overridden events, add the `.wav` to `sounds/` and a new entry to `$EventMap` in
  `Set-WinsonicSounds.ps1`.
