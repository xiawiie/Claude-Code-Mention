$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$helperPath = Join-Path $repoRoot "scripts\mention-audio.ps1"
. $helperPath

function Assert-Equal($actual, $expected, $name) {
  if ($actual -ne $expected) {
    throw "$name expected '$expected' but got '$actual'"
  }
}

function Set-TestEnv($name, $value) {
  if ($null -eq $value) {
    Remove-Item -Path "Env:$name" -ErrorAction SilentlyContinue
  } else {
    Set-Item -Path "Env:$name" -Value $value
  }
}

$savedSound = $env:CLAUDE_MENTION_SOUND
$savedNotificationSound = $env:CLAUDE_MENTION_NOTIFICATION_SOUND
$savedStopSound = $env:CLAUDE_MENTION_STOP_SOUND
$savedNotificationSoundFile = $env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE
$savedStopSoundFile = $env:CLAUDE_MENTION_STOP_SOUND_FILE

$testAudioDir = Join-Path $PSScriptRoot "tmp-audio"
$testWavPath = Join-Path $testAudioDir "custom.wav"
$testMp3Path = Join-Path $testAudioDir "custom.mp3"
$testPluginRoot = Join-Path $PSScriptRoot "tmp-plugin-root"
$testPluginSoundDir = Join-Path $testPluginRoot "sounds"
$testPluginWavPath = Join-Path $testPluginSoundDir "plugin-custom.wav"
$testConfigPath = Join-Path $testPluginSoundDir "config.json"

try {
  New-Item -ItemType Directory -Path $testAudioDir -Force > $null
  New-Item -ItemType Directory -Path $testPluginSoundDir -Force > $null
  Set-Content -Path $testWavPath -Value "test wav placeholder"
  Set-Content -Path $testMp3Path -Value "test mp3 placeholder"
  Set-Content -Path $testPluginWavPath -Value "plugin wav placeholder"
  Set-Content -Path $testConfigPath -Value '{"notification":"plugin-custom.wav","stop":"sounds\\plugin-custom.wav"}'

  Set-TestEnv "CLAUDE_MENTION_SOUND" $null
  Set-TestEnv "CLAUDE_MENTION_NOTIFICATION_SOUND" $null
  Set-TestEnv "CLAUDE_MENTION_STOP_SOUND" $null
  Set-TestEnv "CLAUDE_MENTION_NOTIFICATION_SOUND_FILE" $null
  Set-TestEnv "CLAUDE_MENTION_STOP_SOUND_FILE" $null

  Assert-Equal `
    (Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.IM") `
    '<audio src="ms-winsoundevent:Notification.IM" />' `
    "default sound"

  Set-TestEnv "CLAUDE_MENTION_SOUND" "0"

  Assert-Equal `
    (Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.IM") `
    '<audio silent="true" />' `
    "global mute"

  Set-TestEnv "CLAUDE_MENTION_SOUND" "1"
  Set-TestEnv "CLAUDE_MENTION_NOTIFICATION_SOUND" "ms-winsoundevent:Notification.Reminder"

  Assert-Equal `
    (Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.IM" $env:CLAUDE_MENTION_NOTIFICATION_SOUND) `
    '<audio src="ms-winsoundevent:Notification.Reminder" />' `
    "notification override"

  Set-TestEnv "CLAUDE_MENTION_STOP_SOUND" "ms-winsoundevent:Notification.Default"

  Assert-Equal `
    (Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.IM" $env:CLAUDE_MENTION_STOP_SOUND) `
    '<audio src="ms-winsoundevent:Notification.Default" />' `
    "stop override"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath $testWavPath) `
    (Resolve-Path -LiteralPath $testWavPath).Path `
    "custom wav file"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath "sounds\plugin-custom.wav" $testPluginRoot) `
    (Resolve-Path -LiteralPath $testPluginWavPath).Path `
    "plugin-relative custom wav file"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath "plugin-custom.wav" $testPluginRoot) `
    (Resolve-Path -LiteralPath $testPluginWavPath).Path `
    "plugin sounds folder bare filename"

  Assert-Equal `
    (Get-ClaudeMentionConfiguredSoundFile $testPluginRoot "notification") `
    "plugin-custom.wav" `
    "config notification sound file"

  Assert-Equal `
    (Get-ClaudeMentionConfiguredSoundFile $testPluginRoot "stop") `
    "sounds\plugin-custom.wav" `
    "config stop sound file"

  Assert-Equal `
    (Get-ClaudeMentionEventSoundPath $testPluginRoot "notification" $null) `
    (Resolve-Path -LiteralPath $testPluginWavPath).Path `
    "event sound path uses config file"

  Assert-Equal `
    (Get-ClaudeMentionEventSoundPath $testPluginRoot "notification" $testWavPath) `
    (Resolve-Path -LiteralPath $testWavPath).Path `
    "environment sound file overrides config file"

  Assert-Equal `
    (Test-ClaudeMentionSilentSound "silent") `
    $true `
    "silent keyword"

  Assert-Equal `
    (Test-ClaudeMentionSilentSound "off") `
    $true `
    "off keyword"

  Assert-Equal `
    (Test-ClaudeMentionSilentSound "bright-ping.wav") `
    $false `
    "file name is not silent"

  Set-Content -Path $testConfigPath -Value '{"notification":"silent","stop":""}'

  Assert-Equal `
    (Get-ClaudeMentionEventSoundMode $testPluginRoot "notification" $null) `
    "silent" `
    "config can mute notification event"

  Assert-Equal `
    (Get-ClaudeMentionEventSoundMode $testPluginRoot "stop" $null) `
    "default" `
    "empty config uses default sound"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath $testMp3Path) `
    $null `
    "custom non-wav file"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath (Join-Path $testAudioDir "missing.wav")) `
    $null `
    "missing custom sound file"

  Set-TestEnv "CLAUDE_MENTION_SOUND" "0"

  Assert-Equal `
    (Get-ClaudeMentionCustomSoundPath $testWavPath) `
    $null `
    "custom sound respects global mute"

  Assert-Equal `
    (Get-ClaudeMentionEventSoundPath $testPluginRoot "notification" $null) `
    $null `
    "config sound respects global mute"

  Write-Output "Mention audio tests passed"
} finally {
  Set-TestEnv "CLAUDE_MENTION_SOUND" $savedSound
  Set-TestEnv "CLAUDE_MENTION_NOTIFICATION_SOUND" $savedNotificationSound
  Set-TestEnv "CLAUDE_MENTION_STOP_SOUND" $savedStopSound
  Set-TestEnv "CLAUDE_MENTION_NOTIFICATION_SOUND_FILE" $savedNotificationSoundFile
  Set-TestEnv "CLAUDE_MENTION_STOP_SOUND_FILE" $savedStopSoundFile

  if (Test-Path -LiteralPath $testAudioDir) {
    Remove-Item -LiteralPath $testAudioDir -Recurse -Force
  }

  if (Test-Path -LiteralPath $testPluginRoot) {
    Remove-Item -LiteralPath $testPluginRoot -Recurse -Force
  }
}
