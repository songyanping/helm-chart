param(
    [ValidateSet("watch", "console", "aigc")]
    [string]$AppName = "watch",

    [string]$Env = "devops-opspilot",

    [string]$AppType = "opspilot",

    [string]$BaseUrl = "http://jenkins-ecomm-hk.intranet.local",

    [string]$WebhookToken
)

$ErrorActionPreference = "Stop"

if (-not $WebhookToken) {
    $WebhookToken = $env:JENKINS_DEPLOY_OPSPILOT_WEBHOOK_TOKEN
}

if (-not $WebhookToken) {
    $WebhookToken = [Environment]::GetEnvironmentVariable("JENKINS_DEPLOY_OPSPILOT_WEBHOOK_TOKEN", "User")
}

if (-not $WebhookToken) {
    $WebhookToken = [Environment]::GetEnvironmentVariable("JENKINS_DEPLOY_OPSPILOT_WEBHOOK_TOKEN", "Machine")
}

if (-not $WebhookToken) {
    throw "Missing webhook token. Pass -WebhookToken or set JENKINS_DEPLOY_OPSPILOT_WEBHOOK_TOKEN in Process, User, or Machine environment scope."
}

$uri = $BaseUrl.TrimEnd("/") + "/generic-webhook-trigger/invoke?token=" + [uri]::EscapeDataString($WebhookToken)
$body = [ordered]@{
    ENV = $Env
    APPTYPE = $AppType
    APPNAME = $AppName
} | ConvertTo-Json -Compress

$response = Invoke-WebRequest `
    -Uri $uri `
    -Method Post `
    -ContentType "application/json" `
    -Body $body `
    -UseBasicParsing `
    -TimeoutSec 60

[pscustomobject]@{
    StatusCode = [int]$response.StatusCode
    StatusDescription = $response.StatusDescription
    AppName = $AppName
    Body = $body
    Response = $response.Content
} | ConvertTo-Json -Depth 5
