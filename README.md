# MicFix

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/WingLim/MicFix?include_prereleases)

Fix Headset/Headphone Micphone in Hackintosh with AppleALC.

## Features

- Supports headset plug/unplug.
- Doesn't require `CodecCommander`, `hda-verb` or `alc-verb` to function.

## Usage

Note: Requires AppleALC version 1.5.4+ or the patch of commit [61e2bbf](https://github.com/acidanthera/AppleALC/commit/61e2bbfe74bf1c12ebf770ed4a9776a04a7758f2) applied.

1. Add AppleALC to your OpenCore
2. Enable `alcverbs` by adding `alcverbs=1` to NVRAM->`7C436110-AB2A-4BBB-A880-FE41995C9F82`->`boot-args`
3. Download the newest release, unzip it.

### Install

```bash
bash install.sh
```

### Uninsatll

```bash
bash install.sh uninstall
```

## Supported Devices

The hda-verb command comes from [patch_realtek.c](https://github.com/torvalds/linux/blob/master/sound/pci/hda/patch_realtek.c), but because of the limited devices, only some of them were tested on MacOS.

I'd appreciate it if someone could help me test the devices.

- ALC236
- ALC255[Tested]
- ALC256
- ALC286
- ALC288
- ALC298

## Credits

- [patch_realtek.c](https://github.com/torvalds/linux/blob/master/sound/pci/hda/patch_realtek.c) fro most of the hda-verb command.
- [ComboJack](https://github.com/hackintosh-stuff/ComboJack) for inspiring this project.
