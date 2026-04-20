# claude-code-mention

`claude-code-mention` 是一个适用于 Windows 的 Claude Code 通知插件。它通过 Claude Code hooks 监听事件，在需要你处理消息或 Claude Code 回复完成时弹出 Windows 通知，并播放提示音。

作者：Wei

## 功能特性

- **注意力提醒**：Claude Code 触发 `Notification` 事件时弹出 Windows 通知，例如需要输入、需要工具权限确认等场景。
- **完成提醒**：Claude Code 触发 `Stop` 事件时弹出 “Finished responding” 通知。
- **系统默认提示音**：未做任何配置时，插件使用当前 Windows 通知提示音，也就是系统声音方案里的 `Notification.Default`。
- **五个内置备选音效**：`sounds` 文件夹内提供 5 个本项目生成的 `.wav` 音效，可直接选择使用。
- **自定义提示音**：支持使用插件 `sounds` 文件夹中的 `.wav` 文件，也支持 Windows 内置 `ms-winsoundevent:` 音效。
- **无第三方 PowerShell 依赖**：使用 Windows 原生通知 API 和 PowerShell 标准能力。

## 系统要求

- Windows 10 或 Windows 11
- PowerShell 5.1 或更高版本
- 已安装 Claude Code，并且 Claude Code 支持插件和 hooks

## 项目结构

```text
claude-code-mention/
+-- .claude-plugin/
|   +-- plugin.json
|   +-- marketplace.json
+-- assets/
|   +-- icon.png
+-- hooks/
|   +-- hooks.json
+-- scripts/
|   +-- mention-audio.ps1
|   +-- mention-notification.ps1
|   +-- mention-stop.ps1
+-- sounds/
|   +-- README.md
|   +-- bright-ping.wav
|   +-- calm-bell.wav
|   +-- crystal-drop.wav
|   +-- gentle-chime.wav
|   +-- soft-complete.wav
+-- tests/
|   +-- mention-audio.tests.ps1
+-- LICENSE
+-- README.md
```

## 安装方式

### 方式一：从 GitHub 仓库安装

如果你把项目上传到了 GitHub，例如仓库地址是：

```text
https://github.com/Wei/claude-code-mention
```

可以在 Claude Code 中执行：

```bash
/plugin install Wei/claude-code-mention
```

如果你使用 marketplace 方式：

```bash
/plugin marketplace add Wei/claude-code-mention
/plugin install mention-notifications@claude-code-mention
```

如果你的 GitHub 用户名或仓库名不同，请把 `Wei/claude-code-mention` 替换成你自己的 `用户名/仓库名`。

### 方式二：本地安装

如果项目还在本机目录中，例如：

```text
E:\Data\ChromeDownload\claude-code-mention
```

可以在 Claude Code 中执行：

```bash
/plugin marketplace add E:\Data\ChromeDownload\claude-code-mention
/plugin install mention-notifications@claude-code-mention
```

也可以把路径换成你实际放置项目的位置。

## 使用方式

安装后不需要手动运行脚本。Claude Code 触发 hook 时，插件会自动执行：

| Claude Code 事件 | 执行脚本 | 效果 |
| --- | --- | --- |
| `Notification` | `scripts\mention-notification.ps1` | 弹出注意力提醒，并播放提示音 |
| `Stop` | `scripts\mention-stop.ps1` | 弹出完成提醒，并播放提示音 |

默认情况下，两个事件都会使用当前 Windows 通知提示音：

```text
ms-winsoundevent:Notification.Default
```

这个值会跟随你当前电脑的 Windows 声音方案。插件不会把 Windows 系统音频文件复制进仓库，避免上传 GitHub 时产生版权风险。

## 提示音配置

声音选择优先级如下：

1. `CLAUDE_MENTION_SOUND=0`：完全静音。
2. 用户配置的 `.wav` 文件：`CLAUDE_MENTION_NOTIFICATION_SOUND_FILE` 或 `CLAUDE_MENTION_STOP_SOUND_FILE`。
3. 用户配置的 Windows 内置音效：`CLAUDE_MENTION_NOTIFICATION_SOUND` 或 `CLAUDE_MENTION_STOP_SOUND`。
4. 未做配置时，使用当前 Windows 通知提示音 `ms-winsoundevent:Notification.Default`。

### 临时关闭声音

只在当前终端会话中生效：

```powershell
$env:CLAUDE_MENTION_SOUND = "0"
```

重新启用：

```powershell
$env:CLAUDE_MENTION_SOUND = "1"
```

### 选择内置备选音效

`sounds` 文件夹中已经生成了 5 个可选音效：

| 文件名 | 名字 | 风格 |
| --- | --- | --- |
| `gentle-chime.wav` | 轻柔铃声 | 柔和、清亮，适合作为日常提醒 |
| `crystal-drop.wav` | 水晶落音 | 三段下行音，辨识度更高 |
| `bright-ping.wav` | 明亮提示 | 短促、清晰，适合需要注意的事件 |
| `soft-complete.wav` | 柔和完成 | 上行完成感，适合回复结束 |
| `calm-bell.wav` | 安静钟声 | 较低频、更稳，不刺耳 |

例如，把注意力提醒改成 `bright-ping.wav`，把完成提醒改成 `soft-complete.wav`：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "bright-ping.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "soft-complete.wav"
```

也可以写成插件相对路径：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "sounds\bright-ping.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "sounds\soft-complete.wav"
```

### 使用自己的 WAV 文件

把你的 `.wav` 文件放进 `sounds` 文件夹，例如：

```text
sounds\my-attention.wav
sounds\my-finished.wav
```

然后设置：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "my-attention.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "my-finished.wav"
```

也可以使用绝对路径：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "E:\Sounds\my-attention.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "E:\Sounds\my-finished.wav"
```

### 持久化自定义声音

如果想让设置长期生效，写入 Windows 用户环境变量：

```powershell
[Environment]::SetEnvironmentVariable(
  "CLAUDE_MENTION_NOTIFICATION_SOUND_FILE",
  "bright-ping.wav",
  "User"
)

[Environment]::SetEnvironmentVariable(
  "CLAUDE_MENTION_STOP_SOUND_FILE",
  "soft-complete.wav",
  "User"
)
```

设置后请重启 Claude Code，或打开一个新的终端窗口。

清除持久化配置：

```powershell
[Environment]::SetEnvironmentVariable("CLAUDE_MENTION_NOTIFICATION_SOUND_FILE", $null, "User")
[Environment]::SetEnvironmentVariable("CLAUDE_MENTION_STOP_SOUND_FILE", $null, "User")
```

### 使用 Windows 内置音效

如果你不想使用 `.wav` 文件，也可以指定 Windows 内置音效：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND = "ms-winsoundevent:Notification.Reminder"
$env:CLAUDE_MENTION_STOP_SOUND = "ms-winsoundevent:Notification.Default"
```

常用值：

```text
ms-winsoundevent:Notification.Default
ms-winsoundevent:Notification.IM
ms-winsoundevent:Notification.Mail
ms-winsoundevent:Notification.Reminder
ms-winsoundevent:Notification.SMS
```

## 自定义音效来源

如果你想下载自己的 `.wav` 音效，请查看：

[sounds/README.md](sounds/README.md)

该文档包含：

- 推荐下载网站
- 许可证注意事项
- 适合插件的音效长度和风格
- MP3 转 WAV 方法
- 如何放入 `sounds` 文件夹
- 如何测试自定义音效

## 测试

在项目根目录运行以下命令。

### 测试注意力提醒

```powershell
@{ message = "Test notification"; notification_type = "info" } |
  ConvertTo-Json -Compress |
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\mention-notification.ps1
```

正常情况下，你应该看到一条 Windows 通知，并听到当前 Windows 通知提示音，除非你配置了自定义 `.wav` 文件。

### 测试完成提醒

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\mention-stop.ps1
```

正常情况下，你应该看到 “Finished responding” 通知，并听到当前 Windows 通知提示音，除非你配置了自定义 `.wav` 文件。

### 测试某个备选音效

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "gentle-chime.wav"

@{ message = "Sound choice test"; notification_type = "info" } |
  ConvertTo-Json -Compress |
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\mention-notification.ps1
```

### 测试音频配置逻辑

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\mention-audio.tests.ps1
```

成功时会输出：

```text
Mention audio tests passed
```

## 故障排查

### 没有弹窗

请检查：

- Windows 是否开启了“请勿打扰”或“专注助手”。
- Windows 通知设置是否允许 PowerShell 发送通知。
- Claude Code 是否正确安装了插件。
- `hooks\hooks.json` 是否仍然指向 `scripts\mention-notification.ps1` 和 `scripts\mention-stop.ps1`。
- 是否在远程桌面、沙箱或特殊终端环境中运行；这些环境可能不显示通知横幅。

### 有弹窗但没有声音

请检查：

- 系统音量和通知音量是否为 0。
- `CLAUDE_MENTION_SOUND` 是否被设置为 `0`。
- 自定义 `.wav` 文件是否存在。
- 自定义 `.wav` 文件是否损坏。
- 如果使用自定义文件，路径是否正确。

可以用以下方式验证 `.wav` 文件是否能加载：

```powershell
$player = [System.Media.SoundPlayer]::new((Resolve-Path .\sounds\gentle-chime.wav).Path)
$player.Load()
$player.PlaySync()
```

### 自定义 MP3 没有声音

本插件的本地自定义音效只支持 `.wav`。如果你下载的是 `.mp3`，需要先转换成 `.wav`。转换方法见 [sounds/README.md](sounds/README.md)。

### PowerShell 提示脚本未签名

本插件的 hook 命令已经使用：

```powershell
-ExecutionPolicy Bypass
```

所以 Claude Code 正常触发 hook 时不应被执行策略拦截。如果你手动运行脚本，请也使用 README 中的完整命令。

## 上传到 GitHub 前检查

建议上传前确认：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\mention-audio.tests.ps1
```

并确认以下文件都在仓库中：

```text
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
hooks/hooks.json
scripts/mention-audio.ps1
scripts/mention-notification.ps1
scripts/mention-stop.ps1
sounds/bright-ping.wav
sounds/calm-bell.wav
sounds/crystal-drop.wav
sounds/gentle-chime.wav
sounds/soft-complete.wav
sounds/README.md
README.md
LICENSE
```

如果你的 GitHub 用户名不是 `Wei`，请同步修改 README 中的安装命令，以及 `.claude-plugin\marketplace.json` / `.claude-plugin\plugin.json` 中的作者或 owner 信息。

## 许可证

本项目使用 MIT License。

项目内生成的五个备选音频文件随项目一起按 MIT License 发布。

如果你替换或新增第三方音效，请自行确认其许可证，并在发布时保留必要的来源和署名信息。
