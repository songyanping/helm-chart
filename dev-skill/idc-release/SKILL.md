---
name: idc-release
description: 发布 OpsPilot watch、console、agent 或 aigc 到 IDC Kubernetes 环境。使用主 chart 目录 opspilot，使用本仓库 dev-skill/idc-release 下的 kubeconfig；Helm 不限制固定路径，本地找不到时先下载再执行。适用于用户要求发布、部署、release、upgrade 或更新 IDC 的 OpsPilot watch/console/agent/aigc 版本；需要自动从 gitlab-sre 获取 main 分支最新 push pipeline 推送的 image tag，通过 helm --set 注入 image tag，执行 helm upgrade，并验证 pod、rollout 状态和 deployment 镜像。
---

# IDC 发布

只使用本仓库内的 `dev-skill` 资源，不使用全局 Codex skills 目录，也不要写死任何本机盘符路径。

## 路径规则

所有命令都应先从当前仓库动态解析 skill 路径，兼容不同 PC、不同盘符和不同工作目录：

```powershell
$repoRoot = (git rev-parse --show-toplevel).Trim()
$skillRoot = Join-Path $repoRoot 'dev-skill\idc-release'
$gitlabSreSkillRoot = Join-Path $repoRoot 'dev-skill\gitlab-sre'

$kubeconfig = Join-Path $skillRoot 'assets\idc.kubeconfig'
$chartRoot = Join-Path $repoRoot 'opspilot'
```

如果 `git rev-parse --show-toplevel` 失败，说明当前命令不在仓库内，先 `Set-Location` 到仓库任意子目录后再执行。不要改用绝对路径绕过。

## 发布目标

| 发布目标 | Chart 相对目录 | Values 文件 | Helm release | GitLab 项目路径 | GitLab 地址 | Rollout deployment |
| --- | --- | --- | --- | --- | --- | --- |
| `watch` | `opspilot\watch` | `values.yaml` | `watch` | `alpha/opswatch` | `http://gitlab-sre.intranet.local/alpha/opswatch` | `watch-service`, `watch-exporter` |
| `console` | `opspilot\console` | `values.yaml` | `console` | `alpha/ops-console` | `http://gitlab-sre.intranet.local/alpha/ops-console` | 先用 `kubectl get deploy -n opspilot` 确认 |
| `agent` | `opspilot\agent` | `values.yaml` | `agent` | `alpha/ops-agent` | `http://gitlab-sre.intranet.local/alpha/ops-agent` | `agent-service` |
| `aigc` | `opspilot\aigc` | `values.yaml` | `aigc` | `alpha/opspilot-aigc` | `http://gitlab-sre.intranet.local/alpha/opspilot-aigc` | `aigc-service` |

`ops-agent` 项目的发布目标、Chart 名、Helm release 和镜像仓库名统一叫 `agent`；`alpha/ops-agent` 只作为 GitLab 实际项目路径和 API 查询路径保留。

## 输入规则

必须确认发布目标是 `watch`、`console`、`agent`、`aigc`，或明确指定多个目标一起发布。

如果用户明确指定一个应用，只发布该应用。如果用户只说“发 IDC 版本”但没有指定应用，默认按 `watch` 和 `console` 都发布处理。

不要要求用户提供版本号或镜像 tag。版本号必须通过本仓库内的 `dev-skill/gitlab-sre` 查询得到：取对应项目 `main` 分支最新一次 `source=push` pipeline 推送的 image tag。

如果用户主动提供了 tag，也不要直接信任它；仍然按本规则从 `gitlab-sre` 查询，并报告实际使用的 tag。只有当用户明确要求覆盖自动发现结果时，才可把用户提供的 tag 作为人工指定值，并在继续前再次确认。

## gitlab-sre Tag 获取

使用本仓库内的 `dev-skill/gitlab-sre` 脚本和 GitLab REST API，不要使用浏览器 UI，不要使用全局 skill 路径。

查询最新 pipeline：

```powershell
$repoRoot = (git rev-parse --show-toplevel).Trim()
$gitlabSreSkillRoot = Join-Path $repoRoot 'dev-skill\gitlab-sre'
$gitlabApi = Join-Path $gitlabSreSkillRoot 'scripts\gitlab-sre-api.ps1'

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File $gitlabApi `
  -Method GET `
  -Path "/projects/<urlencoded-project-path>/pipelines?ref=main&source=push&order_by=id&sort=desc&per_page=5"
```

查询 pipeline jobs：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File $gitlabApi `
  -Method GET `
  -Path "/projects/<urlencoded-project-path>/pipelines/<pipeline-id>/jobs?per_page=100"
```

优先读取 image build job trace。若存在 `build_image_idc`，优先使用它；否则读取名称包含 `build_image` 或 `image` 的构建 job：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File $gitlabApi `
  -Method GET `
  -Path "/projects/<urlencoded-project-path>/jobs/<job-id>/trace"
```

提取规则：

- 接受形如 `Pushing image to <registry>/<namespace>/<project>:<tag>` 的 tag。
- 忽略空 tag，例如日志中的 `<image>:`。
- 如果多个 registry 推送了同一个非空 tag，使用该 tag。
- 如果多个非空 tag 不一致，停止并报告冲突，不要发布。
- 记录 pipeline id、commit short SHA、job id、完整镜像地址和 tag，最终报告给用户。
- 如果自动获取 tag 失败、为空或存在冲突，不要修改 Helm chart，也不要执行 helm upgrade。

## Helm tag 注入

不要为了发布 tag 修改 values 文件。主业务镜像 tag 必须在 `helm upgrade` 时通过 `--set` 注入：

- `watch`: `--set image.tag="<tag>"`
- `console`: `--set image.tag="<tag>"`
- `agent`: `--set agent.image.tag="<tag>"`，不要覆盖 `ccConnect.image.tag`
- `aigc`: `--set image.tag="<tag>"`

发布前展示每个目标应用的旧 tag -> 新 tag，并展示 tag 来源摘要。

## Helm 命令

必须显式传入 IDC kubeconfig，不要依赖默认 kubeconfig。

Helm 路径不做固定限制。优先使用本机 `PATH` 中的 `helm`；如果本机找不到 Helm，先下载 Helm，再使用下载得到的可执行文件。不要再依赖仓库内固定 Helm 路径。

统一命令前置变量：

```powershell
$repoRoot = (git rev-parse --show-toplevel).Trim()
$skillRoot = Join-Path $repoRoot 'dev-skill\idc-release'
$kubeconfig = Join-Path $skillRoot 'assets\idc.kubeconfig'
$chartRoot = Join-Path $repoRoot 'opspilot'

$helmCommand = Get-Command helm -ErrorAction SilentlyContinue
if ($helmCommand) {
  $helm = $helmCommand.Source
} else {
  $helmVersion = 'v3.15.4'
  $helmDir = Join-Path $repoRoot '.tools\helm'
  $zipPath = Join-Path $helmDir "helm-$helmVersion-windows-amd64.zip"
  New-Item -ItemType Directory -Force -Path $helmDir | Out-Null
  Invoke-WebRequest -Uri "https://get.helm.sh/helm-$helmVersion-windows-amd64.zip" -OutFile $zipPath
  Expand-Archive -LiteralPath $zipPath -DestinationPath $helmDir -Force
  $helm = Join-Path $helmDir 'windows-amd64\helm.exe'
}
```

发布 `watch`：

```powershell
Set-Location -LiteralPath (Join-Path $chartRoot 'watch')
& $helm --kubeconfig $kubeconfig -n opspilot upgrade watch . --set image.tag="<tag>"
```

发布 `console`：

```powershell
Set-Location -LiteralPath (Join-Path $chartRoot 'console')
& $helm --kubeconfig $kubeconfig -n opspilot upgrade console . --set image.tag="<tag>"
```

发布 `agent`：

```powershell
Set-Location -LiteralPath (Join-Path $chartRoot 'agent')
& $helm --kubeconfig $kubeconfig -n opspilot upgrade agent . --set agent.image.tag="<tag>"
```

发布 `aigc`：

```powershell
Set-Location -LiteralPath (Join-Path $chartRoot 'aigc')
& $helm --kubeconfig $kubeconfig -n opspilot upgrade aigc . --set image.tag="<tag>"
```

如果网络或 Kubernetes API 访问被沙箱拦截，使用相同命令申请提升权限后重跑，不要改命令绕过。

## 验证

统一验证前置变量：

```powershell
$repoRoot = (git rev-parse --show-toplevel).Trim()
$skillRoot = Join-Path $repoRoot 'dev-skill\idc-release'
$kubeconfig = Join-Path $skillRoot 'assets\idc.kubeconfig'
```

基础 pod 检查：

```powershell
kubectl.exe --kubeconfig $kubeconfig get pod -n opspilot
```

验证 `watch`：

```powershell
kubectl.exe --kubeconfig $kubeconfig rollout status deploy/watch-service -n opspilot --timeout=120s
kubectl.exe --kubeconfig $kubeconfig rollout status deploy/watch-exporter -n opspilot --timeout=120s
kubectl.exe --kubeconfig $kubeconfig get deploy watch-service watch-exporter -n opspilot -o jsonpath="{range .items[*]}{.metadata.name}{' '}{range .spec.template.spec.containers[*]}{.name}{'='}{.image}{' resources='}{.resources}{' '}{end}{'\n'}{end}"
```

验证 `console`：

```powershell
kubectl.exe --kubeconfig $kubeconfig get deploy -n opspilot
kubectl.exe --kubeconfig $kubeconfig rollout status deploy/<console-deployment> -n opspilot --timeout=120s
kubectl.exe --kubeconfig $kubeconfig get deploy <console-deployment> -n opspilot -o jsonpath="{range .items[*]}{.metadata.name}{' '}{range .spec.template.spec.containers[*]}{.name}{'='}{.image}{' '}{end}{'\n'}{end}"
```

验证 `agent`：

```powershell
kubectl.exe --kubeconfig $kubeconfig rollout status deploy/agent-service -n opspilot --timeout=120s
kubectl.exe --kubeconfig $kubeconfig get deploy agent-service -n opspilot -o jsonpath="{range .items[*]}{.metadata.name}{' '}{range .spec.template.spec.containers[*]}{.name}{'='}{.image}{' resources='}{.resources}{' '}{end}{'\n'}{end}"
```

验证 `aigc`：

```powershell
kubectl.exe --kubeconfig $kubeconfig rollout status deploy/aigc-service -n opspilot --timeout=120s
kubectl.exe --kubeconfig $kubeconfig get deploy aigc-service -n opspilot -o jsonpath="{range .items[*]}{.metadata.name}{' '}{range .spec.template.spec.containers[*]}{.name}{'='}{.image}{' resources='}{.resources}{' '}{end}{'\n'}{end}"
```

发布成功证据应包含：

- Helm 输出中有 `STATUS: deployed`。
- 新建或刚重建的应用 pod 处于 `Running`。
- 对应 deployment 的 `rollout status` 成功。
- deployment 镜像包含自动获取并用于发布的 tag。

旧 pod 短暂处于 `Terminating` 可以接受，前提是 rollout 成功且新 pod 已 ready。

## 汇报

汇报时包含：

- 已发布的应用。
- 自动获取并发布的 tag，以及来源 pipeline/job 摘要。
- 修改的文件，以及旧 tag -> 新 tag。
- Helm release 状态和 revision。
- pod、rollout、deployment 镜像验证结果。

不要在回复中暴露 kubeconfig 内容、token、证书或其他密钥。
