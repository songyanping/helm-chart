param(
  [Parameter(Mandatory = $true)]
  [string] $SourceBranch,

  [string] $TargetBranch = "master",

  [string] $Title = "Update files",

  [string] $Project = "sre%2Fopspilot%2Fhelm-charts%2Fopspilot-chart",

  [string] $BaseUrl = "http://gitlab-hk.intranet.local/api/v4"
)

$ErrorActionPreference = "Stop"

$token = [Environment]::GetEnvironmentVariable("GITLAB_HK_TOKEN", "Process")
if (-not $token) { $token = [Environment]::GetEnvironmentVariable("GITLAB_HK_TOKEN", "User") }
if (-not $token) { $token = [Environment]::GetEnvironmentVariable("GITLAB_HK_TOKEN", "Machine") }
if (-not $token) { throw "GITLAB_HK_TOKEN was not found in Process, User, or Machine environment." }

$headers = @{ "PRIVATE-TOKEN" = $token }

function Convert-ApiError($ErrorRecord) {
  $response = $ErrorRecord.Exception.Response
  $body = ""
  if ($response) {
    try {
      $reader = [System.IO.StreamReader]::new($response.GetResponseStream())
      $body = $reader.ReadToEnd()
    } catch {
      $body = ""
    }
  }

  [pscustomobject]@{
    status = if ($response) { [int]$response.StatusCode } else { $null }
    message = $ErrorRecord.Exception.Message
    body = $body
  }
}

function Write-Result($Value) {
  $Value | ConvertTo-Json -Depth 8
}

$encodedSource = [uri]::EscapeDataString($SourceBranch)
$encodedTarget = [uri]::EscapeDataString($TargetBranch)
$mrListUri = "$BaseUrl/projects/$Project/merge_requests?state=opened&source_branch=$encodedSource&target_branch=$encodedTarget"

try {
  $mrs = @(Invoke-RestMethod -Method Get -Headers $headers -Uri $mrListUri)
  if ($mrs.Count -gt 0) {
    $mr = $mrs[0]
    $created = $false
  } else {
    $createBody = @{
      source_branch = $SourceBranch
      target_branch = $TargetBranch
      title = $Title
      remove_source_branch = $true
    } | ConvertTo-Json

    $mr = Invoke-RestMethod `
      -Method Post `
      -Headers $headers `
      -ContentType "application/json" `
      -Uri "$BaseUrl/projects/$Project/merge_requests" `
      -Body $createBody
    $created = $true
  }
} catch {
  Write-Result ([pscustomobject]@{
    ok = $false
    stage = "create_or_find_mr"
    source_branch = $SourceBranch
    target_branch = $TargetBranch
    error = Convert-ApiError $_
  })
  exit 1
}

Start-Sleep -Seconds 2

try {
  $merged = Invoke-RestMethod `
    -Method Put `
    -Headers $headers `
    -Uri "$BaseUrl/projects/$Project/merge_requests/$($mr.iid)/merge" `
    -Body @{
      should_remove_source_branch = "true"
    }

  Write-Result ([pscustomobject]@{
    ok = $true
    stage = "merged"
    created = $created
    iid = $mr.iid
    web_url = $mr.web_url
    state = $merged.state
    merge_status = $merged.merge_status
    merge_commit_sha = $merged.merge_commit_sha
  })
} catch {
  $mergeError = Convert-ApiError $_
  try {
    $mergeWhenPipelineSucceeds = Invoke-RestMethod `
      -Method Put `
      -Headers $headers `
      -Uri "$BaseUrl/projects/$Project/merge_requests/$($mr.iid)/merge" `
      -Body @{
        merge_when_pipeline_succeeds = "true"
        should_remove_source_branch = "true"
      }

    Write-Result ([pscustomobject]@{
      ok = $true
      stage = "merge_when_pipeline_succeeds"
      created = $created
      iid = $mr.iid
      web_url = $mr.web_url
      state = $mergeWhenPipelineSucceeds.state
      merge_status = $mergeWhenPipelineSucceeds.merge_status
      merge_commit_sha = $mergeWhenPipelineSucceeds.merge_commit_sha
      first_merge_error = $mergeError
    })
  } catch {
    Write-Result ([pscustomobject]@{
      ok = $false
      stage = "merge"
      created = $created
      iid = $mr.iid
      web_url = $mr.web_url
      merge_status = $mr.merge_status
      first_merge_error = $mergeError
      error = Convert-ApiError $_
    })
    exit 1
  }
}
