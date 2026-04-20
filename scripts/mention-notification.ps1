# mention-notification.ps1
# Reads Claude Code hook JSON from stdin and shows a Windows notification with the message.

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
  $data = $raw | ConvertFrom-Json
} catch {
  exit 0
}

# Claude Code Notification input includes `message` and usually `notification_type`
# https://code.claude.com/docs/en/hooks (Notification Input)
$title = "Claude Code"
$line1 = if ($data.notification_type) { "Type: $($data.notification_type)" } else { "Notification" }
$line2 = if ($data.message) { [string]$data.message } else { "(no message)" }

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

# Build notification XML with or without icon
$imageXml = if (Test-Path $iconPath) {
  "<image placement=`"appLogoOverride`" src=`"file:///$($iconPath -replace '\\','/')`"/>"
} else { "" }
$customSoundPath = Get-ClaudeMentionEventSoundPath $pluginRoot "notification" $env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE
$soundMode = Get-ClaudeMentionEventSoundMode $pluginRoot "notification" $env:CLAUDE_MENTION_NOTIFICATION_SOUND_FILE
$audioXml = if ($soundMode -eq "silent" -or $customSoundPath) {
  '<audio silent="true" />'
} else {
  Get-ClaudeMentionAudioXml "ms-winsoundevent:Notification.Default" $env:CLAUDE_MENTION_NOTIFICATION_SOUND
}

$notificationXmlText = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$(Escape-Xml $title)</text>
      <text>$(Escape-Xml $line1)</text>
      <text>$(Escape-Xml $line2)</text>
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
