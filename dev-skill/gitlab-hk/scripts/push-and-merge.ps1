param(
  [string] $SourceBranch,

  [string] $TargetBranch = "master",

  [string] $Title = "Update files",

  [string] $Remote = "origin",

  [string] $Project = "sre%2Fopspilot%2Fhelm-charts%2Fopspilot-chart",

  [string] $BaseUrl = "http://gitlab-hk.intranet.local/api/v4"
)

$ErrorActionPreference = "Stop"

if (-not $SourceBranch) {
  $SourceBranch = (git branch --show-current).Trim()
}

if (-not $SourceBranch) {
  throw "SourceBranch was not provided and the current Git branch could not be detected."
}

$status = git status --porcelain
if ($status) {
  throw "Working tree is not clean. Commit or discard changes before push-and-merge."
}

git push -u $Remote $SourceBranch

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $scriptDir "merge-request.ps1") `
  -SourceBranch $SourceBranch `
  -TargetBranch $TargetBranch `
  -Title $Title `
  -Project $Project `
  -BaseUrl $BaseUrl
