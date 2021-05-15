# MicFix

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/WingLim/MicFix?include_prereleases)

Fix Headset/Headphone Micphone in Hackintosh with AppleALC.

## Usage

Download the newest release, unzip it.

### Install

```bash
bash install.sh
```

### Uninsatll

```bash
bash install.sh uninstall
```

## Features

- Supports headset plug/unplug.
- Doesn't require `CodecCommander`, `hda-verb` or `alc-verb` to function.

Note: Requires AppleALC version 1.5.4+ or the patch of commit [61e2bbf](https://github.com/acidanthera/AppleALC/commit/61e2bbfe74bf1c12ebf770ed4a9776a04a7758f2) applied.

## Supported Devices

The hda-verb command comes from [ComboJack](https://github.com/hackintosh-stuff/ComboJack), but because of the limited devices, only some of them were tested.

I'd appreciate it if someone could help me test the devices.

- ALC255[Tested]

## Credits

- [ComboJack](https://github.com/hackintosh-stuff/ComboJack) for hda-verb command to fix micphone.
