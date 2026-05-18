---
title: "Sound Lock — Support"
date: 2026-05-18 22:26:00
tags:
    - Sound Lock
---

# Sound Lock — Support

Sound Lock is a tiny macOS menu-bar utility that locks your preferred audio input / output / system output and quietly switches them back whenever macOS auto-flips to a wrong device (most commonly when a Bluetooth headset's microphone forces playback into low-quality HFP/SCO).

- **System requirements**: macOS 14.0+, Apple Silicon or Intel
- **App Sandbox**: enabled
- **Data collection**: none — see the [Privacy Policy](/docs/soundlock-privacy-policy/)

---

## Quick start

1. After installing, look for the speaker-shaped icon in the top-right **menu bar** (Sound Lock has no Dock icon — that's by design)
2. Click the icon → **Preferences** to open the main window
3. In **Device Lock → Input** (or Output), click the lock icon next to a device to make it your preferred device
4. macOS will now auto-revert to that device within ~0.4 seconds whenever something else takes over

---

## Sound Lock Pro

Free tier: up to **2 device locks total** across input + output. Lock a 3rd device to trigger the Pro upgrade sheet.

Sound Lock Pro is a one-time purchase (Non-Consumable IAP) that unlocks unlimited device locks. The same Apple ID restores it on any of your Macs.

---

## FAQ

**Q: Why doesn't the menu bar icon appear after install?**
On macOS Tahoe (26+), third-party menu bar items need explicit permission. Open *System Settings → Control Center → Menu Bar* and make sure Sound Lock is allowed.

**Q: Does Sound Lock record audio?**
No. Sound Lock only calls the public CoreAudio HAL API to change the **default device selection**. It never opens an audio stream, never accesses the microphone, never analyzes audio.

**Q: Bluetooth headset still drops to low quality during video calls — does Sound Lock help?**
Yes — that's exactly what it was built for. Lock your AirPods (or any A2DP-capable output) as the preferred output, and lock the laptop's built-in microphone as the preferred input. When Zoom / Teams / Meet try to switch your headset's mic on, Sound Lock will switch the system mic back to built-in within a fraction of a second, keeping the headset in A2DP for high-quality playback.

**Q: My device disappeared from the priority list.**
Cached display names are kept across reboots, so an unplugged device should remain visible (greyed out). If it's completely gone, the macOS audio system may have forgotten its UID — reconnect once and it will reappear.

**Q: How do I restore my Pro purchase on a new Mac?**
Open *Preferences → Upgrade Pro → Restore Purchases*. Make sure you're signed in to the App Store with the same Apple ID.

---

## Contact

Bug reports, feature requests, or anything else: **oldcai.com@gmail.com**

---

# Sound Lock — 支持

Sound Lock 是一个常驻 macOS 菜单栏的小工具，记住你想要的麦克风 / 耳机 / 音箱，每当 macOS 把默认输入或输出"乱切"到其他设备时，Sound Lock 会在不到半秒内自动切回。

- **系统要求**：macOS 14.0+，Apple Silicon 或 Intel
- **App Sandbox**：已开启
- **数据收集**：无 — 详见 [隐私政策](/docs/soundlock-privacy-policy/)

---

## 快速上手

1. 安装后在屏幕右上角 **菜单栏** 找喇叭样图标（Sound Lock 没有 Dock 图标，这是设计）
2. 点击图标 → **偏好设置** 打开主窗口
3. 在 **设备锁定 → 输入**（或输出）tab 中，点击设备旁的锁定图标
4. 此后每当 macOS 切到其他设备，Sound Lock 会在 ~0.4 秒内切回你锁定的设备

---

## Sound Lock Pro

免费版：输入 + 输出 **总共最多锁定 2 个设备**。锁第 3 个时会触发 Pro 升级弹窗。

Sound Lock Pro 是一次买断（Non-Consumable IAP），解锁不限数量的设备锁。同一个 Apple ID 可以在你的多台 Mac 上恢复购买。

---

## 常见问题

**菜单栏没看到图标？**
macOS Tahoe (26+) 起第三方菜单栏项需要额外授权。打开 *系统设置 → 控制中心 → 菜单栏*，确保 Sound Lock 在允许列表里。

**Sound Lock 会录音吗？**
不会。Sound Lock 只调用 macOS 公开的 CoreAudio HAL API 切换 **默认设备选择**，从不打开音频流，从不访问麦克风，从不分析音频。

**蓝牙耳机开会时还是会掉到低音质，Sound Lock 能解决吗？**
能 —— 这正是它设计的初衷。把 AirPods（或任何支持 A2DP 的输出）锁为优先输出，把笔记本内置麦克风锁为优先输入。当 Zoom / Teams / Meet 试图切换到耳机麦克风时，Sound Lock 会在不到半秒内把系统麦克风切回内置麦克风，保持耳机停留在 A2DP 高音质播放。

**设备从优先列表里消失了？**
缓存的显示名跨重启保留，断开的设备应仍然可见（灰显）。如果完全消失，可能是 macOS 音频系统忘记了它的 UID —— 重连一次就会重新出现。

**新 Mac 上怎么恢复 Pro 购买？**
打开 *偏好设置 → 升级 Pro → 恢复购买*，确保你在 App Store 登录的是同一个 Apple ID。

---

## 联系

Bug 反馈、功能建议、任何问题：**oldcai.com@gmail.com**
