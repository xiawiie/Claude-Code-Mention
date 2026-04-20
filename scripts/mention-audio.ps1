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
