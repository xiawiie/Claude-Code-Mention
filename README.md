# claude-code-mention

`claude-code-mention` 是一个适用于 Windows 的 Claude Code 通知插件。它通过 Claude Code hooks 监听事件，在 Claude Code 需要你处理消息或回复完成时弹出 Windows 通知，并播放提示音。

作者 / GitHub：xiawiie

## 功能特性

- **注意力提醒**：Claude Code 触发 `Notification` 事件时弹出 Windows 通知，例如需要输入、需要工具权限确认等场景。
- **完成提醒**：Claude Code 触发 `Stop` 事件时弹出 “Finished responding” 通知。
- **默认使用系统通知音**：未配置时使用当前电脑的 Windows 通知提示音 `ms-winsoundevent:Notification.Default`。
- **简单音效配置**：只需要编辑 `sounds\config.json`，不用手动设置环境变量。
- **五个内置备选音效**：`sounds` 文件夹内提供 5 个本项目生成的 `.wav` 音效。
- **支持静默通知**：可以单独设置注意力提醒或完成提醒为只弹窗、不播放声音。
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
|   +-- config.json
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

### 从 GitHub 安装（推荐，已验证）

仓库地址：

```text
https://github.com/xiawiie/Claude-Code-Mention
```

在终端中执行：

```powershell
claude plugin marketplace add xiawiie/Claude-Code-Mention --scope user
claude plugin install mention-notifications@claude-code-mention --scope user
```

安装成功后可以查看插件状态：

```powershell
claude plugin list
```

你应该能看到类似条目：

```text
mention-notifications@claude-code-mention
Status: √ enabled
```

注意：不要直接执行 `claude plugin install xiawiie/Claude-Code-Mention`。Claude Code CLI 的 `plugin install` 会从已配置的 marketplace 中查找插件，因此必须先执行 `claude plugin marketplace add`。

### 本地安装（开发调试）

如果项目在本机目录中，例如：

```text
E:\Data\ChromeDownload\claude-code-mention
```

可以在终端中执行：

```powershell
claude plugin marketplace add E:\Data\ChromeDownload\claude-code-mention --scope user
claude plugin install mention-notifications@claude-code-mention --scope user
```

如果只是临时测试，不想写入全局用户配置，可以把 `--scope user` 改成 `--scope local`，并在临时目录中执行。

## 使用方式

安装后不需要手动运行脚本。Claude Code 触发 hook 时，插件会自动执行：

| Claude Code 事件 | 执行脚本 | 效果 |
| --- | --- | --- |
| `Notification` | `scripts\mention-notification.ps1` | 弹出注意力提醒 |
| `Stop` | `scripts\mention-stop.ps1` | 弹出完成提醒 |

默认情况下，两个事件都会使用当前 Windows 通知提示音：

```text
ms-winsoundevent:Notification.Default
```

这个值会跟随你当前电脑的 Windows 声音方案。插件不会把 Windows 系统音频文件复制进仓库，避免上传 GitHub 时产生版权风险。

## 最简单的提示音设置方式

以后要改提示音，只需要编辑这个文件：

```text
sounds\config.json
```

默认内容是：

```json
{
  "notification": "",
  "stop": ""
}
```

含义：

| 字段 | 控制事件 | 留空时 |
| --- | --- | --- |
| `notification` | Claude Code 需要你注意时的通知 | 使用当前 Windows 通知提示音 |
| `stop` | Claude Code 回复完成时的通知 | 使用当前 Windows 通知提示音 |

### 选择内置音效

`sounds` 文件夹中有 5 个可选音效：

| 文件名 | 名字 | 风格 |
| --- | --- | --- |
| `gentle-chime.wav` | 轻柔铃声 | 柔和、清亮，适合作为日常提醒 |
| `crystal-drop.wav` | 水晶落音 | 三段下行音，辨识度更高 |
| `bright-ping.wav` | 明亮提示 | 短促、清晰，适合需要注意的事件 |
| `soft-complete.wav` | 柔和完成 | 上行完成感，适合回复结束 |
| `calm-bell.wav` | 安静钟声 | 较低频、更稳，不刺耳 |

例如，把注意力提醒改成 `bright-ping.wav`，把完成提醒改成 `soft-complete.wav`：

```json
{
  "notification": "bright-ping.wav",
  "stop": "soft-complete.wav"
}
```

保存 `sounds\config.json` 后，下次 Claude Code 触发通知就会使用新音效。

### 设置静默通知

如果你希望只弹窗、不播放声音，把对应字段写成 `silent`：

```json
{
  "notification": "bright-ping.wav",
  "stop": "silent"
}
```

上面的配置表示：

- `Notification` 事件播放 `bright-ping.wav`
- `Stop` 事件只弹出通知，不播放声音

也可以两个都静默：

```json
{
  "notification": "silent",
  "stop": "silent"
}
```

可用的静默值包括：

```text
silent
mute
muted
off
none
```

推荐统一使用 `silent`。

### 使用自己的 WAV 文件

把你的 `.wav` 文件放进 `sounds` 文件夹，例如：

```text
sounds\my-attention.wav
sounds\my-finished.wav
```

然后把 `sounds\config.json` 改成：

```json
{
  "notification": "my-attention.wav",
  "stop": "my-finished.wav"
}
```

建议在 `config.json` 中只写文件名，不写 `sounds\...` 路径，这样最不容易出错。

### 恢复系统默认通知音

把字段改回空字符串即可：

```json
{
  "notification": "",
  "stop": ""
}
```

## 高级配置：环境变量

一般用户只需要改 `sounds\config.json`。环境变量保留给高级用法或临时测试。

完全静音：

```powershell
$env:CLAUDE_MENTION_SOUND = "0"
```

临时指定某个 `.wav` 文件：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "bright-ping.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "soft-complete.wav"
```

临时指定 Windows 内置音效：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND = "ms-winsoundevent:Notification.Reminder"
$env:CLAUDE_MENTION_STOP_SOUND = "ms-winsoundevent:Notification.Default"
```

声音选择优先级：

1. `CLAUDE_MENTION_SOUND=0`：完全静音。
2. 环境变量中的 `.wav` 文件。
3. `sounds\config.json` 中的文件名或 `silent`。
4. 环境变量中的 Windows 内置音效。
5. 当前 Windows 通知提示音 `ms-winsoundevent:Notification.Default`。

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

### 测试完成提醒

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\mention-stop.ps1
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

- `sounds\config.json` 是否把对应字段设置成了 `silent`。
- `CLAUDE_MENTION_SOUND` 是否被设置为 `0`。
- 系统音量和通知音量是否为 0。
- 自定义 `.wav` 文件是否存在。
- 自定义 `.wav` 文件是否损坏。
- `config.json` 是否是合法 JSON。

可以用以下方式验证 `.wav` 文件是否能加载：

```powershell
$player = [System.Media.SoundPlayer]::new((Resolve-Path .\sounds\gentle-chime.wav).Path)
$player.Load()
$player.PlaySync()
```

### 修改 config.json 后没有生效

请检查：

- 文件路径是否是 `sounds\config.json`。
- JSON 中字符串是否使用英文双引号。
- 是否多写了逗号。
- 文件名是否和 `sounds` 文件夹里的 `.wav` 完全一致。
- 如果你用了环境变量，环境变量会优先于 `config.json`。

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

也建议验证插件 manifest：

```powershell
claude plugin validate .
```

并确认以下文件都在仓库中：

```text
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
hooks/hooks.json
scripts/mention-audio.ps1
scripts/mention-notification.ps1
scripts/mention-stop.ps1
sounds/config.json
sounds/bright-ping.wav
sounds/calm-bell.wav
sounds/crystal-drop.wav
sounds/gentle-chime.wav
sounds/soft-complete.wav
sounds/README.md
README.md
LICENSE
```

## 许可证

本项目使用 MIT License。

项目内生成的五个备选音频文件随项目一起按 MIT License 发布。

如果你替换或新增第三方音效，请自行确认其许可证，并在发布时保留必要的来源和署名信息。
