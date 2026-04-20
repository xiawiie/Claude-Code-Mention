# sounds 音效目录说明

这个目录用于存放 `claude-code-mention` 的 `.wav` 提示音文件，也包含最简单的音效配置文件：

```text
config.json
```

## 最简单的设置方式

打开 `sounds\config.json`：

```json
{
  "notification": "",
  "stop": ""
}
```

两个字段的含义：

| 字段 | 控制事件 | 留空时 |
| --- | --- | --- |
| `notification` | Claude Code 需要你注意时的通知 | 使用当前 Windows 通知提示音 |
| `stop` | Claude Code 回复完成时的通知 | 使用当前 Windows 通知提示音 |

要换声音，只需要把字段改成这个文件夹里的 `.wav` 文件名。

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

## 配置示例

### 注意力提醒用明亮提示，完成提醒用柔和完成

```json
{
  "notification": "bright-ping.wav",
  "stop": "soft-complete.wav"
}
```

### 注意力提醒有声音，完成提醒静默

```json
{
  "notification": "bright-ping.wav",
  "stop": "silent"
}
```

### 两个通知都静默

```json
{
  "notification": "silent",
  "stop": "silent"
}
```

### 恢复系统默认通知音

```json
{
  "notification": "",
  "stop": ""
}
```

## 静默选项

如果你希望只弹出通知、不播放声音，可以把字段写成：

```text
silent
```

也支持这些同义值：

```text
mute
muted
off
none
```

推荐统一使用 `silent`，最清楚。

## 使用自己的音效

你也可以把自己的 `.wav` 文件放进本目录，例如：

```text
my-attention.wav
my-finished.wav
```

然后把 `config.json` 改成：

```json
{
  "notification": "my-attention.wav",
  "stop": "my-finished.wav"
}
```

要求：

- 必须是 `.wav` 格式。
- 建议时长控制在 `0.2` 到 `1.5` 秒。
- 建议音量不要太大，避免频繁提醒时打扰。
- 建议在 `config.json` 中只写文件名，不写路径。

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

## MP3 转 WAV

插件的本地自定义音效只支持 `.wav`。如果下载的是 `.mp3`，需要先转换。

### 使用 ffmpeg

```powershell
ffmpeg -i input.mp3 -ac 1 -ar 44100 sounds\my-attention.wav
```

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

### 改了 config.json 但没有生效

检查：

- `config.json` 是否在 `sounds` 文件夹里。
- JSON 是否使用英文双引号。
- 文件名是否和 `.wav` 文件完全一致。
- 是否多写了逗号。
- 是否有环境变量覆盖了配置。

### 想恢复电脑当前默认提示音

把 `config.json` 改回：

```json
{
  "notification": "",
  "stop": ""
}
```

未配置自定义音效时，插件会使用当前 Windows 通知提示音。
