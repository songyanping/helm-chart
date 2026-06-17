# AGENTS.md

本文档定义本仓库的项目规范和本地 skill 路径。所有在本仓库工作的 Codex/Agent，在执行任何操作前都必须先阅读本文档。

## 项目范围

- 仓库根目录必须通过 `git rev-parse --show-toplevel` 动态解析。
- OpsPilot 主 Helm Chart 位于 `opspilot/`：
  - `opspilot/watch`
  - `opspilot/console`
  - `opspilot/agent`
  - `opspilot/aigc`
- 中间件 Helm Chart 位于 `middleware/`。
- 项目本地 skill 位于 `dev-skill/`。

废弃路径：

- 不要使用或重新创建 `dev-skill/idc-release/assets/helmcharts`。
- 所有 Chart 修改、lint、template 和发布都必须使用 `opspilot/` 下的主 Chart 路径。

## 操作规则

- 只做满足用户请求所需的最小变更。
- 不要回滚、覆盖或删除用户已有改动，除非用户明确要求。
- 涉及编辑时，按需先用 `git status --short` 查看当前工作区状态。
- 搜索文件或内容时优先使用 `rg` / `rg --files`。
- 手工编辑文件时优先使用 `apply_patch`。
- 不要在回复中暴露 kubeconfig 内容、token、证书、Secret 值、docker 凭据或其他敏感信息。
- 未经用户明确要求，不要 commit、push、创建合并请求、merge 或删除分支。
- 如果命令因为沙箱网络或集群访问限制失败，使用相同命令申请提升权限后重跑，不要改变流程绕过限制。

## 本地 Skill 路径

遇到职责相同或相近的场景时，优先使用本仓库 `dev-skill` 下的项目本地 skill，不要优先使用全局 skill。

```powershell
$repoRoot = (git rev-parse --show-toplevel).Trim()
$idcReleaseSkill = Join-Path $repoRoot 'dev-skill\idc-release\SKILL.md'
$gitlabSreSkill = Join-Path $repoRoot 'dev-skill\gitlab-sre\SKILL.md'
$chartRoot = Join-Path $repoRoot 'opspilot'
```

必须使用 skill 的场景：

- IDC 发布、部署、升级、Helm、Kubernetes rollout、kubeconfig、OpsPilot `watch` / `console` / `agent` / `aigc` 发布任务：读取并遵循 `dev-skill/idc-release/SKILL.md`。
- `gitlab-sre.intranet.local` 的 GitLab API、pipeline、job、trace、branch、commit、合并请求、镜像 tag 发现任务：读取并遵循 `dev-skill/gitlab-sre/SKILL.md`。
- 两者都适用时，先读 `idc-release`，再读 `gitlab-sre`。

## 发布路径规则

IDC 发布使用：

- Helm：不限制固定路径。优先使用本机 `PATH` 中的 `helm`；找不到时先下载 Helm，再使用下载得到的可执行文件。
- kubeconfig：`dev-skill/idc-release/assets/idc.kubeconfig`
- Chart 根目录：`opspilot`

发布目标映射：

| 应用 | Chart 路径 | Helm release |
| --- | --- | --- |
| `watch` | `opspilot/watch` | `watch` |
| `console` | `opspilot/console` | `console` |
| `agent` | `opspilot/agent` | `agent` |
| `aigc` | `opspilot/aigc` | `aigc` |

发布镜像 tag 必须通过 `dev-skill/gitlab-sre` 从对应项目 `main` 分支最新 `source=push` pipeline 中发现，除非用户明确要求覆盖自动发现结果。

不要为了发布镜像 tag 修改 `values.yaml`。发布 tag 必须按 `dev-skill/idc-release/SKILL.md` 使用 `helm upgrade --set` 注入。

## Helm Chart 规范

- 保持现有 Chart 结构、helper 模板、labels、values 层级和命名约定。
- 不要在模板中硬编码 `metadata.namespace`。
- Chart 默认值应尽量保持稳定和向后兼容。
- 不要把 kubeconfig、docker config、证书、Secret 原文等运行凭据复制进主 Chart。
- Chart 修改后，尽量使用本地 Helm 执行相关验证：

```powershell
$helmCommand = Get-Command helm -ErrorAction SilentlyContinue
if ($helmCommand) {
  $helm = $helmCommand.Source
} else {
  $helmVersion = 'v3.15.4'
  $helmDir = Join-Path (git rev-parse --show-toplevel).Trim() '.tools\helm'
  $zipPath = Join-Path $helmDir "helm-$helmVersion-windows-amd64.zip"
  New-Item -ItemType Directory -Force -Path $helmDir | Out-Null
  Invoke-WebRequest -Uri "https://get.helm.sh/helm-$helmVersion-windows-amd64.zip" -OutFile $zipPath
  Expand-Archive -LiteralPath $zipPath -DestinationPath $helmDir -Force
  $helm = Join-Path $helmDir 'windows-amd64\helm.exe'
}
& $helm lint opspilot\watch
& $helm template watch opspilot\watch
```

非 `watch` Chart 按实际 Chart 路径调整命令。

## Watch Chart 约束

除非用户明确要求调整，`opspilot/watch/values.yaml` 必须保持以下 `exporter` 资源模型：

```yaml
exporter:
  resourcesPreset: "small"
  resources: {}
  mainResources:
    limits:
      cpu: 1
      memory: 4Gi
    requests:
      cpu: 1
      memory: 4Gi
  hourResources:
    limits:
      cpu: 300m
      memory: 1Gi
    requests:
      cpu: 300m
      memory: 1Gi
  replicaCount: 1
  extraEnvVars: {}
```

`opspilot/watch/templates/exporter.yaml` 必须支持：

- `exporter-main` 优先使用 `.Values.exporter.mainResources`。
- `exporter-hour` 优先使用 `.Values.exporter.hourResources`。
- 缺少专用资源配置时回退到 `.Values.exporter.resources`。
- 仍缺少资源配置时回退到 `resourcesPreset`。

## 回复要求

代码或 Chart 变更的最终回复应包含：

- 修改了哪些文件。
- 执行了哪些验证。
- 哪些验证未能执行以及原因。

发布任务的最终回复应包含：

- 发布的应用和 tag。
- tag 来源 pipeline/job 摘要。
- Helm release 状态和 revision。
- rollout、Pod、镜像和资源配置验证结果。
