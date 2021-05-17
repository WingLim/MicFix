# MicFix

![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/WingLim/MicFix?include_prereleases)

使用 AppleALC 修复黑苹果上头戴耳机/耳塞的麦克风。

[English](https://github.com/WingLim/MicFix/blob/main/README.md) | 中文

## 特性

- 支持耳机热拔插。
- 不需要 `CodecCommander`, `hda-verb` 或者 `alc-verb` 来驱动。

## 使用方法

注意: 需要 AppleALC 1.5.4+ 或者应用了这个 commit [61e2bbf](https://github.com/acidanthera/AppleALC/commit/61e2bbfe74bf1c12ebf770ed4a9776a04a7758f2)。

1. OpenCore 中启用 AppleALC。
2. 添加 `alcverbs=1` 到 NVRAM->`7C436110-AB2A-4BBB-A880-FE41995C9F82`->`boot-args` 来启用 `alcverbs`。
3. 下载最新的发布版，并解压。

### 安装

```bash
bash install.sh
```

### 卸载

```bash
bash install.sh uninstall
```

## 支持的设备

修复麦克风的 hda-verb 命令来自 [patch_realtek.c](https://github.com/torvalds/linux/blob/master/sound/pci/hda/patch_realtek.c)，但因为缺少设备，只有一部分在 MacOS 上测试过。

如果有人能帮忙测试这些设备，我们将会十分感谢。

- ALC236
- ALC255[已测试]
- ALC256
- ALC286
- ALC288
- ALC298

## 感谢

- [patch_realtek.c](https://github.com/torvalds/linux/blob/master/sound/pci/hda/patch_realtek.c) 提供了绝大多数的 hda-verb 命令。
- [ComboJack](https://github.com/hackintosh-stuff/ComboJack) 为本项目提供了灵感。
