function Get-ClaudeMentionAudioXml {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DefaultSound,

    [string]$OverrideSound
  )

  if ($env:CLAUDE_MENTION_SOUND -eq "0") {
    return '<audio silent="true" />'
  }

  $sound = if ([string]::IsNullOrWhiteSpace($OverrideSound)) {
    $DefaultSound
  } else {
    $OverrideSound
  }

  $escapedSound = [System.Security.SecurityElement]::Escape($sound)
  return "<audio src=`"$escapedSound`" />"
}

function Get-ClaudeMentionCustomSoundPath {
  param(
    [string]$SoundFile,

    [string]$PluginRoot
  )

  if ($env:CLAUDE_MENTION_SOUND -eq "0") {
    return $null
  }

  if ([string]::IsNullOrWhiteSpace($SoundFile)) {
    return $null
  }

  $candidates = @($SoundFile)

  if (![System.IO.Path]::IsPathRooted($SoundFile) -and ![string]::IsNullOrWhiteSpace($PluginRoot)) {
    $candidates += (Join-Path $PluginRoot $SoundFile)

    if ([string]::IsNullOrWhiteSpace([System.IO.Path]::GetDirectoryName($SoundFile))) {
      $candidates += (Join-Path (Join-Path $PluginRoot "sounds") $SoundFile)
    }
  }

  $resolved = $null
  foreach ($candidate in $candidates) {
    $resolved = Resolve-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
    if ($null -ne $resolved) {
      break
    }
  }

  if ($null -eq $resolved) {
    return $null
  }

  $path = $resolved.Path
  if ([System.IO.Path]::GetExtension($path).ToLowerInvariant() -ne ".wav") {
    return $null
  }

  return $path
}

function Test-ClaudeMentionSilentSound {
  param(
    [string]$SoundFile
  )

  if ([string]::IsNullOrWhiteSpace($SoundFile)) {
    return $false
  }

  $normalized = $SoundFile.Trim().ToLowerInvariant()
  return $normalized -in @("silent", "mute", "muted", "off", "none")
}

function Get-ClaudeMentionConfiguredSoundFile {
  param(
    [string]$PluginRoot,

    [ValidateSet("notification", "stop")]
    [string]$EventName
  )

  if ([string]::IsNullOrWhiteSpace($PluginRoot)) {
    return $null
  }

  $configPath = Join-Path (Join-Path $PluginRoot "sounds") "config.json"
  if (!(Test-Path -LiteralPath $configPath)) {
    return $null
  }

  try {
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
  } catch {
    return $null
  }

  $value = if ($EventName -eq "notification") {
    $config.notification
  } else {
    $config.stop
  }

  if ([string]::IsNullOrWhiteSpace($value)) {
    return $null
  }

  return [string]$value
}

function Get-ClaudeMentionEventSoundPath {
  param(
    [string]$PluginRoot,

    [ValidateSet("notification", "stop")]
    [string]$EventName,

    [string]$EnvironmentSoundFile
  )

  if ($env:CLAUDE_MENTION_SOUND -eq "0") {
    return $null
  }

  $soundPath = Get-ClaudeMentionCustomSoundPath $EnvironmentSoundFile $PluginRoot
  if ($soundPath) {
    return $soundPath
  }

  $configuredFile = Get-ClaudeMentionConfiguredSoundFile $PluginRoot $EventName
  return Get-ClaudeMentionCustomSoundPath $configuredFile $PluginRoot
}

function Get-ClaudeMentionEventSoundMode {
  param(
    [string]$PluginRoot,

    [ValidateSet("notification", "stop")]
    [string]$EventName,

    [string]$EnvironmentSoundFile
  )

  if ($env:CLAUDE_MENTION_SOUND -eq "0") {
    return "silent"
  }

  if (Test-ClaudeMentionSilentSound $EnvironmentSoundFile) {
    return "silent"
  }

  $environmentPath = Get-ClaudeMentionCustomSoundPath $EnvironmentSoundFile $PluginRoot
  if ($environmentPath) {
    return "file"
  }

  $configuredFile = Get-ClaudeMentionConfiguredSoundFile $PluginRoot $EventName
  if (Test-ClaudeMentionSilentSound $configuredFile) {
    return "silent"
  }

  $configuredPath = Get-ClaudeMentionCustomSoundPath $configuredFile $PluginRoot
  if ($configuredPath) {
    return "file"
  }

  return "default"
}

function Invoke-ClaudeMentionCustomSound {
  param(
    [string]$SoundPath
  )

  if ([string]::IsNullOrWhiteSpace($SoundPath)) {
    return $false
  }

  try {
    $player = [System.Media.SoundPlayer]::new($SoundPath)
    $player.Load()
    $player.PlaySync()
    return $true
  } catch {
    return $false
  }
}
