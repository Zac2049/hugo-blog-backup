---
title: "Mac 上制作 Win11 安装 U 盘"
date: 2025-05-09T10:00:00+08:00
draft: false
tags: ["技术", "工具"]
categories: ["笔记"]
math: true
---

下面是\*\*基于你遇到的问题（install.wim 太大，`mv` 失败）\*\*之后，**修正优化的完整终端操作步骤**。我们将采取 **先复制 install.wim 到本地磁盘，再使用 `wimlib` 分割后写入 U 盘** 的方式，确保整个流程稳定、可靠，适配 Windows 11 的安装要求。

---

## ✅ Mac 上制作 Win11 安装 U 盘（分割 install.wim，适配 >4GB）

### 📦 前提准备

| 项目   | 要求                                                            |
| ---- | ------------------------------------------------------------- |
| 系统镜像 | 下载 Win11 官方 ISO                                               |
| U 盘  | ≥8GB，建议使用 **ExFAT** 格式，避免 FAT32 限制                            |
| 工具   | Terminal，Homebrew，wimlib                                      |
| 文件路径 | 本文示例路径使用：`/Volumes/WIN11` 为 U 盘，`~/Desktop/install.wim` 为中转文件 |

---

## 🛠️ 全流程操作步骤

### 🔹1. 插入 U 盘并查看设备号

```bash
diskutil list
```

确认你的 U 盘设备号（如 `/dev/disk2`），**请替换下面命令中的设备号！**

---

### 🔹2. 格式化 U 盘为 ExFAT + GPT

```bash
diskutil eraseDisk ExFAT WIN11 GPT /dev/disk2
```

> `WIN11` 为卷标名，可自定义。ExFAT 支持大文件写入。

---

### 🔹3. 挂载 Windows 11 ISO 镜像

```bash
hdiutil mount ~/Downloads/Win11_*.iso
```

> 通常会挂载为 `/Volumes/PCHA_X64FREO_ZH-CN_DV9`（中文 ISO）或类似路径，请记住它。

---

### 🔹4. 安装 wimlib（如未安装）

```bash
brew install wimlib
```

---

### 🔹5. 复制 install.wim 到本地桌面

```bash
cp /Volumes/PCHA_X64FREO_ZH-CN_DV9/sources/install.wim ~/Desktop/install.wim
```

> 📌 不直接写入 U盘，避免失败。

---

### 🔹6. 拷贝其他安装文件（不包括 install.wim）

```bash
rsync -avh /Volumes/PCHA_X64FREO_ZH-CN_DV9/ /Volumes/WIN11/
```

---

### 🔹7. 分割 install.wim 并写入 U 盘

```bash
wimlib-imagex split ~/Desktop/install.wim /Volumes/WIN11/sources/install.swm 3800
```

> 将大于 4GB 的 install.wim 分割为多个 install.swm/install2.swm 文件

---

### 🔹8. 清理本地临时文件（可选）

```bash
rm ~/Desktop/install.wim
```

---

### 🔹9. 卸载镜像和弹出 U 盘（可选）

```bash
hdiutil unmount /Volumes/PCHA_X64FREO_ZH-CN_DV9
diskutil eject /dev/disk2
```

---

## ✅ 安装时使用说明

1. 将制作好的 U 盘插入目标电脑
2. 开机按 `F12` / `ESC` / `F8` 进入启动菜单
3. 从 USB UEFI 启动
4. 安装过程会自动识别 `install.swm` 文件，无需手动干预

---

## ✅ 总结检查表

| 步骤                  | 是否解决问题              |
| ------------------- | ------------------- |
| 避免 install.wim 写入失败 | ✅ 使用本地复制解决          |
| FAT32 兼容性限制         | ✅ 使用 ExFAT 格式解决     |
| 安装文件完整性             | ✅ 使用 rsync + swm 保证 |
| 安装兼容性（UEFI 启动）      | ✅ GPT + ExFAT 满足    |

---

如你希望我将以上步骤封装成一个 **带变量提示的 shell 脚本**，只需输入 ISO 路径和设备号即可一键执行，我可以立刻帮你生成。是否需要？
