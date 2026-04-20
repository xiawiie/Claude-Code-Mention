# sounds 音效目录说明

这个目录用于存放 `claude-code-mention` 的 `.wav` 提示音文件。

## 默认音效说明

插件默认不复制 Windows 系统音频文件，也不把系统音频文件放进仓库。

未配置自定义音效时，插件使用当前电脑的 Windows 通知提示音：

```text
ms-winsoundevent:Notification.Default
```

这样做有两个好处：

- 会跟随你当前 Windows 声音方案。
- 不会把 Windows 系统媒体文件复制到 GitHub 仓库里，避免版权风险。

## 本目录中的可选音效

本目录提供 5 个项目内生成的备选 `.wav` 音效。每个音频都有独立文件名和名字：

| 文件名 | 名字 | 风格 |
| --- | --- | --- |
| `gentle-chime.wav` | 轻柔铃声 | 柔和、清亮，适合作为日常提醒 |
| `crystal-drop.wav` | 水晶落音 | 三段下行音，辨识度更高 |
| `bright-ping.wav` | 明亮提示 | 短促、清晰，适合需要注意的事件 |
| `soft-complete.wav` | 柔和完成 | 上行完成感，适合回复结束 |
| `calm-bell.wav` | 安静钟声 | 较低频、更稳，不刺耳 |

这些音频是项目内生成的短提示音，随项目一起按 MIT License 发布。

## 选择一个备选音效

例如，把注意力提醒改成 `bright-ping.wav`：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "bright-ping.wav"
```

把完成提醒改成 `soft-complete.wav`：

```powershell
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "soft-complete.wav"
```

也可以写成插件相对路径：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "sounds\bright-ping.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "sounds\soft-complete.wav"
```

如果想长期生效，写入 Windows 用户环境变量：

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

设置后请重启 Claude Code，或打开新的终端窗口。

## 使用自己的音效

你也可以把自己的 `.wav` 文件放进本目录，例如：

```text
my-attention.wav
my-finished.wav
```

然后配置：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "my-attention.wav"
$env:CLAUDE_MENTION_STOP_SOUND_FILE = "my-finished.wav"
```

要求：

- 必须是 `.wav` 格式。
- 建议时长控制在 `0.2` 到 `1.5` 秒。
- 建议音量不要太大，避免频繁提醒时打扰。

## 去哪里下载 WAV 音效

推荐来源：

| 网站 | 地址 | 说明 |
| --- | --- | --- |
| Mixkit | https://mixkit.co/free-sound-effects/ | 适合找短 UI 音效、提示音；下载前确认使用的是 Sound Effects Free License。 |
| Pixabay Sound Effects | https://pixabay.com/sound-effects/ | 资源很多，适合搜索 notification、beep、ding、success 等关键词。 |
| Freesound | https://freesound.org/ | 很多文件本身就是 `.wav`；务必查看每个音效自己的许可证，优先选择 CC0。 |
| ZapSplat | https://www.zapsplat.com/ | 资源多，但免费账户可能需要署名，WAV 下载可能需要 Premium。 |
| BBC Sound Effects | https://sound-effects.bbcrewind.co.uk/ | 适合个人实验；许可证限制较多，不建议直接随公开插件发布。 |

推荐搜索关键词：

```text
notification wav
message notification wav
ui beep wav
success ding wav
soft alert wav
subtle notification wav
complete sound wav
short chime wav
```

## 选择音效的建议

适合这个插件的音效通常是：

```text
时长：0.2 到 1.5 秒
格式：.wav
风格：清晰、短促、柔和、不刺耳
音量：中等或偏低
```

不建议使用：

- 很长的音乐片段
- 突然很响的警报声
- 高频刺耳声音
- 带有人声或复杂旋律的片段
- 电影、游戏、动漫、商业软件中未经授权的音效

## 许可证注意事项

下载音效前请检查许可证。

- **CC0 / Public Domain**：最省心，通常不要求署名。
- **CC BY / Attribution**：通常可以使用，但必须保留作者署名。
- **NonCommercial / NC**：不建议使用，除非你确认只用于非商业场景。
- **未知许可证**：不要使用。

如果你要把音效文件一起上传到 GitHub，请保留来源记录。例如可以新建一个 `SOUND_CREDITS.md`，写明：

```text
文件：my-attention.wav
来源：https://example.com/sound
作者：作者名
许可证：CC0 或 CC BY
下载日期：YYYY-MM-DD
```

如果你只是自己本机使用，不公开发布，也仍然建议保留来源记录，方便以后追溯。

## MP3 转 WAV

插件的本地自定义音效只支持 `.wav`。如果下载的是 `.mp3`，需要先转换。

### 使用 ffmpeg

```powershell
ffmpeg -i input.mp3 -ac 1 -ar 44100 sounds\my-attention.wav
```

参数说明：

- `-ac 1`：转成单声道。
- `-ar 44100`：采样率设为 44100 Hz。
- `sounds\my-attention.wav`：输出到插件的 `sounds` 文件夹。

### 使用 Audacity

1. 用 Audacity 打开 MP3。
2. 选择 `File`。
3. 选择 `Export Audio`。
4. 格式选择 WAV。
5. 保存到这个 `sounds` 文件夹。

## 测试某个音效

在项目根目录运行：

```powershell
$env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE = "gentle-chime.wav"

@{ message = "Sound choice test"; notification_type = "info" } |
  ConvertTo-Json -Compress |
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\mention-notification.ps1
```

如果你看到 Windows 通知并听到声音，说明配置有效。

## 常见问题

### 放了文件但没有声音

检查：

- 文件是否真的是 `.wav`。
- 文件名是否写错。
- 文件是否放在 `sounds` 文件夹中。
- 环境变量是否写成了正确的文件名。
- `CLAUDE_MENTION_SOUND` 是否被设置为 `0`。
- 系统音量或通知音量是否为 0。

### 想恢复电脑当前默认提示音

清除自定义文件环境变量即可：

```powershell
[Environment]::SetEnvironmentVariable("CLAUDE_MENTION_NOTIFICATION_SOUND_FILE", $null, "User")
[Environment]::SetEnvironmentVariable("CLAUDE_MENTION_STOP_SOUND_FILE", $null, "User")
```

然后重启 Claude Code。未配置自定义音效时，插件会继续使用当前 Windows 通知提示音。
