param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE")]
  [string] $Method,

  [Parameter(Mandatory = $true)]
  [string] $Path,

  [Parameter(Mandatory = $false)]
  [string] $BodyJson
)

$ErrorActionPreference = "Stop"

if (-not $Path.StartsWith("/")) {
  throw "Path must start with '/'. Example: /projects/group%2Fproject"
}

$token = $env:GITLAB_SRE_TOKEN
if (-not $token) {
  $token = [Environment]::GetEnvironmentVariable("GITLAB_SRE_TOKEN", "User")
}
if (-not $token) {
  $token = [Environment]::GetEnvironmentVariable("GITLAB_SRE_TOKEN", "Machine")
}
if (-not $token) {
  throw "GITLAB_SRE_TOKEN is not set in Process, User, or Machine environment."
}

$baseUrl = "http://gitlab-sre.intranet.local/api/v4"
$uri = "$baseUrl$Path"
$headers = @{
  "PRIVATE-TOKEN" = $token
}

$params = @{
  Method = $Method
  Uri = $uri
  Headers = $headers
}

if ($BodyJson) {
  $params["ContentType"] = "application/json"
  $params["Body"] = $BodyJson
}

$response = Invoke-RestMethod @params
$response | ConvertTo-Json -Depth 20
