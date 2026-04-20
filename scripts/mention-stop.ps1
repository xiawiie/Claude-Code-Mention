# mention-stop.ps1

# Icon path relative to script location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptDir
$iconPath = (Resolve-Path (Join-Path $scriptDir "..\assets\icon.png") -ErrorAction SilentlyContinue).Path
. (Join-Path $scriptDir "mention-audio.ps1")

# Load Windows.UI.Notifications (native notification API)
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null

# Escape XML special characters
function Escape-Xml($text) {
  return [System.Security.SecurityElement]::Escape($text)
}

$title = "Claude Code"
$message = "Finished responding"

# Build notification XML with or without icon
$imageXml = if (Test-Path $iconPath) {
  "<image placement=`"appLogoOverride`" src=`"file:///$($iconPath -replace '\\','/')`"/>"
} else { "" }
$customSoundPath = Get-ClaudeMentionEventSoundPath $pluginRoot "stop" $env:CLAUDE_MENTION_STOP_SOUND_FILE
$soundMode = Get-ClaudeMentionEventSoundMode $pluginRoot "stop" $env:CLAUDE_MENTION_STOP_SOUND_FILE
$audioXml = if ($soundMode -eq "silent" -or $customSoundPath) {
  '<audio silent="true" />'
} else {
  Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.Default" $env:CLAUDE_MENTION_STOP_SOUND
}

$notificationXmlText = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$(Escape-Xml $title)</text>
      <text>$(Escape-Xml $message)</text>
      $imageXml
    </binding>
  </visual>
  $audioXml
</toast>
"@

# Show the Windows notification
$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$xml.LoadXml($notificationXmlText)
$notification = [Windows.UI.Notifications.ToastNotification]::new($xml)
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($notification)
if ($soundMode -eq "file") {
  Invoke-ClaudeMentionCustomSound $customSoundPath > $null
}
