+++
title = 'Tmux使用指南'
date = 2026-05-15T16:59:21+08:00
draft = false
tags = ["工具", "效率"]
categories = ["笔记"]
+++

`tmux` (Terminal Multiplexer) 是一个终端复用器，允许你在一个终端窗口中管理多个会话、窗口和面板。即使断开 SSH 连接，`tmux` 中运行的任务也会继续在后台运行。

---

## 核心概念

`tmux` 有三层层级结构：

1. **Session (会话)** — 最顶层容器，可包含多个窗口。
2. **Window (窗口)** — 类似浏览器标签页，可分成多个面板。
3. **Pane (面板)** — 窗口中的分栏。

---

## 安装

```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux

# CentOS
sudo yum install tmux
```

---

## 前缀键 (Prefix)

`tmux` 的所有快捷键都需要先按前缀键，默认是 **`Ctrl + b`**（下文简写为 `C-b`），松开后再按后续按键。

---

## 会话管理 (Session)

| 动作 | 外部命令 | 内部快捷键 (C-b + ...) |
| --- | --- | --- |
| 新建并命名会话 | `tmux new -s <name>` | — |
| 分离当前会话 | — | `d` |
| 查看所有会话 | `tmux ls` | `s` |
| 接入指定会话 | `tmux a -t <name>` | — |
| 杀死指定会话 | `tmux kill-session -t <name>` | — |
| 重命名当前会话 | — | `$` |

---

## 窗口管理 (Window)

| 动作 | 快捷键 (C-b + ...) |
| --- | --- |
| 新建窗口 | `c` |
| 关闭当前窗口 | `&` |
| 上一个窗口 | `p` |
| 下一个窗口 | `n` |
| 按数字切换 | `0-9` |
| 重命名窗口 | `,` |
| 窗口列表选择 | `w` |

---

## 面板管理 (Pane)

| 动作 | 快捷键 (C-b + ...) |
| --- | --- |
| 左右分屏 | `%` |
| 上下分屏 | `"` |
| 切换面板 | `方向键` 或 `o` |
| 关闭当前面板 | `x` |
| 全屏/恢复 (Zoom) | `z` |
| 显示面板编号 | `q` |
| 面板转为窗口 | `!` |
| 与前一个面板互换 | `{` |
| 与后一个面板互换 | `}` |
| 顺时针轮转所有面板 | `Ctrl + o` |
| 循环切换布局 | `Space` |

**精确交换面板**：`C-b` → `:` 进入命令模式，输入 `swap-pane -s 1 -t 3`。

---

## 复制模式与滚动

在 `tmux` 中查看历史输出需要进入复制模式：

1. 进入：`C-b` + `[`
2. 移动：方向键 / `PageUp` / `PageDown` / `g`(顶部) / `G`(底部)
3. 搜索：`?` 向上搜索，`/` 向下搜索，`n`/`N` 跳转匹配项
4. 选择复制：`Space` 开始选择 → `Enter` 复制
5. 粘贴：`C-b` + `]`
6. 退出：`q`

---

## 鼠标模式

开启鼠标支持后，可以直接滚轮翻页、点击切换面板、拖动调整面板大小：

```bash
# 临时生效
tmux set -g mouse on

# 永久生效：写入 ~/.tmux.conf
set -g mouse on
```

> [!TIP]
> 开启鼠标模式后，想用鼠标选中文字复制到系统剪贴板，需要按住 **Shift** 再拖动选择。

---

## 推荐配置 (~/.tmux.conf)

```bash
# 前缀键改为 Ctrl + a（更顺手）
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# 开启鼠标
set -g mouse on

# 窗口/面板起始序号为 1
set -g base-index 1
set -w -g pane-base-index 1

# 256 色支持
set -g default-terminal "screen-256color"
```

修改后在 `tmux` 内执行 `tmux source-file ~/.tmux.conf` 生效。

---

## 常见工作流

1. **远程办公**：`tmux new -s work` 开始工作，下班 `C-b d` 分离，回家 `tmux a -t work` 接回。
2. **多任务并行**：左面板写代码，右面板 `tail -f` 看日志。
3. **防掉线**：耗时任务必须在 `tmux` 里运行，SSH 断开也不影响。

---

## Q&A

### 如何在 tmux 中启动训练任务并离线运行？

**场景**：启动一个长时间运行的训练 → 退出终端 → 中途回来查看进度。

**操作步骤**：

```bash
# 1. 创建专用会话
tmux new -s train_v1

# 2. 在会话中启动训练（建议 tee 同时输出到文件）
conda activate my_ml_env
python train.py --epochs 100 2>&1 | tee train.log

# 3. 分离会话：C-b d
#    看到提示 [detached (from session train_v1)] 即成功
#    此时关掉终端/断网都不影响训练

# 4. 中途查看进度
tmux a -t train_v1

# 5. 训练完成后关闭会话
exit
```

**查看技巧**：

- 翻页查看历史 Loss：`C-b [` 进入复制模式，用 `PageUp` 翻页，`q` 退出
- 分屏监控 GPU：`C-b "` 上下分屏，在新面板执行 `nvidia-smi -l 1`

> [!TIP]
> 网络突然断开不用担心，`tmux` 会自动 Detach。重新 SSH 登录后 `tmux a -t train_v1` 即可恢复现场。

---

### 如何像普通终端一样用滚轮翻页和搜索？

**方法一：开启鼠标模式（推荐）**

```bash
# 写入 ~/.tmux.conf 永久生效
set -g mouse on
```

开启后滚轮即可直接翻页，滚到底部自动回到实时输出。

**方法二：纯键盘操作**

| 动作 | 快捷键 |
| --- | --- |
| 进入翻页模式 | `C-b [` |
| 上/下翻页 | `PageUp` / `PageDown` |
| 逐行滚动 | `方向键 上/下` |
| 跳转顶部/底部 | `g` / `G` |
| 向上搜索关键词 | `?keyword` + Enter |
| 向下搜索关键词 | `/keyword` + Enter |
| 下一个/上一个匹配 | `n` / `N` |
| 退出 | `q` |

---

### 如何互换面板位置？

| 方式 | 操作 |
| --- | --- |
| 与前一个面板互换 | `C-b {` |
| 与后一个面板互换 | `C-b }` |
| 所有面板顺时针轮转 | `C-b Ctrl+o` |
| 循环切换布局 | `C-b Space` |
| 精确交换指定面板 | `C-b :` → `swap-pane -s 1 -t 3` |

> [!TIP]
> 按 `C-b q` 可以显示面板编号，数字小的为"前一个"面板。
