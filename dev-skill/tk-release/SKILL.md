---
name: tk-release
description: 编排 OpsPilot watch、console 和/或 aigc 的 TK 环境发布。当用户要求发布、部署、release 或更新 TK 版本时使用；若未明确指定项目，默认发布所有项目。
---

# TK Release

使用此 skill 发布 OpsPilot TK 环境版本。可发布单个项目：`watch`、`console` 或 `aigc`；如果用户未明确指定项目，默认依次发布所有项目：`watch`、`console` 和 `aigc`。

此 skill 是编排器：
1. 使用 `gitlab-sre` 自动获取要发布的 image tag。
2. 使用 `gitlab-hk` 在 GitLab 中更新所选 Helm `values.yaml` 的 app image tag。
3. 在 GitLab 变更合并到 `master` 后，使用 `jenkins-hk` 触发 Jenkins `deploy_opspilot` job。

## 项目选择

项目必须是 `watch`、`console` 或 `aigc`。

- 如果用户明确指定 `watch`、`console` 或 `aigc`，只发布指定项目。
- 如果用户明确要求“全部”、“所有项目”、“都发一遍”等，发布 `watch`、`console` 和 `aigc`。
- 如果用户只说“发 TK 版本”、“发布 TK”、“release TK”等而未明确项目，视为默认发布 `watch`、`console` 和 `aigc`，不要再为了项目选择向用户追问。
- 多项目发布时按固定顺序执行：先 `watch`，后 `console`，最后 `aigc`；每个项目仍按本 skill 的 tag 获取、GitLab 变更、验证和 Jenkins 触发流程独立处理。

不要要求用户提供版本号/tag。版本号必须由 `gitlab-sre` 查询得到：

| 项目 | tag 来源规则 |
| --- | --- |
| `console` | `alpha/ops-console` 项目 `main-tw` 分支最后一次成功 push pipeline 推送的 image tag |
| `aigc` | `alpha/opspilot-aigc` 项目 `main` 分支最新 tag |
| 其他项目 | 对应 gitlab-sre 项目 `main` 分支最后一次 push pipeline 推送的 image tag |

如果用户主动提供了 tag，也不要直接信任它；仍然按上表从 `gitlab-sre` 查询并报告实际使用的 tag。只有当用户明确要求覆盖自动发现结果时，才可把用户提供的 tag 作为人工指定值，并在继续前再次确认。

## gitlab-sre Tag 获取

使用 `gitlab-sre` skill 和 GitLab REST API，不要使用浏览器 UI。

项目映射：

| 发布项目 | gitlab-sre 项目路径 | 分支/规则 |
| --- | --- | --- |
| `watch` | `alpha/opswatch` | `main` 最后一次 push pipeline 的 image tag |
| `console` | `alpha/ops-console` | `main-tw` 最后一次成功 push pipeline 的 image tag |
| `aigc` | `alpha/opspilot-aigc` | `main` 分支最新 tag |

### 获取 console tag

对 `alpha/ops-console` 查询 `ref=main-tw&source=push` 的最新成功 pipeline，然后读取 `build_image_tw` job trace，提取 `Pushing image to ...:<tag>` 中的非空 tag。不要使用 `alpha/opsconsole`；实际项目路径带连字符。不要依赖 repository tags，`main-tw` 分支通常没有对应的 `main-tw` tag。

常用 API：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fops-console/pipelines?ref=main-tw&source=push&order_by=id&sort=desc&per_page=5"
```

然后查询最新成功 pipeline 的 jobs：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fops-console/pipelines/<pipeline-id>/jobs?per_page=100"
```

读取 `build_image_tw` job trace：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fops-console/jobs/<job-id>/trace"
```

从 trace 中选择 `ops-console:<tag>` 的非空 tag 作为 image tag。若找不到 `build_image_tw` 或非空 tag，停止并向用户报告无法自动确定版本。

### 获取 aigc main 分支最新 tag

对 `alpha/opspilot-aigc` 读取 `main` 分支的最新 tag，不要使用 pipeline trace 推断。查询 repository tags，按更新时间或创建时间倒序检查 tag，并选择其 commit 属于 `main` 分支的第一个 tag 作为 image tag。

常用 API：
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fopspilot-aigc/repository/tags?order_by=updated&sort=desc&per_page=20"
```

如需确认某个 tag 的 commit 是否在 `main` 分支上，查询该 commit 的 branch refs：
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fopspilot-aigc/repository/commits/<commit-sha>/refs?type=branch"
```

只有返回 refs 中包含 `main` 时，才可使用该 tag。若找不到属于 `main` 分支的 tag，停止并向用户报告无法自动确定 aigc 版本。

### 获取 watch 和其他 main-push tag

对对应 gitlab-sre 项目查询 `ref=main&source=push` 的最新 pipeline，然后读取该 pipeline 的 image build job trace，提取 `Pushing image to ...:<tag>` 中的非空 tag。

常用 API：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fopswatch/pipelines?ref=main&source=push&order_by=id&sort=desc&per_page=5"
```

然后查询最新 pipeline 的 jobs：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fopswatch/pipelines/<pipeline-id>/jobs?per_page=100"
```

优先读取 `build_image_pd` job；如果还有 `build_image_idc`，可用它交叉确认 tag 是否一致。读取 trace：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-sre/scripts/gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/alpha%2Fopswatch/jobs/<job-id>/trace"
```

提取规则：
- 接受形如 `Pushing image to <registry>/<namespace>/<project>:<tag>` 的 tag。
- 忽略空 tag，例如日志中的 `<image>:`。
- 如果多个 registry 推送了同一个非空 tag，使用该 tag。
- 如果多个非空 tag 不一致，停止并向用户报告冲突，不要发布。
- 记录 pipeline id、commit short SHA、job id、完整镜像地址和 tag，最终报告给用户。

## 项目目标

根据所选项目选择 Helm values 文件：

| 项目 | `opspilot-chart` 中的本地路径 | GitLab 文件 |
| --- | --- | --- |
| `watch` | `helmchart/opspilot/watch/values.yaml` | `http://gitlab-hk.intranet.local/sre/opspilot/helm-charts/opspilot-chart/-/blob/master/helmchart/opspilot/watch/values.yaml` |
| `console` | `helmchart/opspilot/console/values.yaml` | `http://gitlab-hk.intranet.local/sre/opspilot/helm-charts/opspilot-chart/-/blob/master/helmchart/opspilot/console/values.yaml` |
| `aigc` | `helmchart/opspilot/aigc/values.yaml` | `http://gitlab-hk.intranet.local/sre/opspilot/helm-charts/opspilot-chart/-/blob/master/helmchart/opspilot/aigc/values.yaml` |

仓库：
`http://gitlab-hk.intranet.local/sre/opspilot/helm-charts/opspilot-chart.git`

目标分支：
`master`

## 发布工作流

1. 按“项目选择”规则确定目标项目列表。
2. 按上面的 `gitlab-sre` 规则为每个目标项目自动获取 tag，并向用户展示来源摘要。
3. 调用 `gitlab-hk` 执行 Helm chart 变更：
   - 从 `master` 开始工作。
   - 只编辑目标项目的 values 文件。
   - 只将 app image 的 `tag` 值替换为自动获取的 tag。
   - 不要修改 `configmapReload.image.tag` 等 helper image tag。
   - 在 commit/push/MR/merge 前展示 diff 并要求确认。
   - 允许时推送到 `master`。
   - 如果 `master` 受保护，创建或复用功能分支，创建到 `master` 的 MR，并在 `gitlab-hk` 凭据允许时尝试自动合并。
   - 只有在变更合并到 `master` 后才继续；否则带着 MR/阻塞原因停止。
4. 验证 `origin/master` 包含自动获取的 app image tag。
5. 通过 Generic Webhook Trigger 端点调用 `jenkins-hk` 执行部署：
   - URL: `http://jenkins-ecomm-hk.intranet.local/generic-webhook-trigger/invoke?token=deploy-opspilot`
   - Method: `POST`
   - Header: `Content-Type: application/json`
   - watch 的 body: `{"ENV":"devops-opspilot","APPTYPE":"opspilot","APPNAME":"watch"}`
   - console 的 body: `{"ENV":"devops-opspilot","APPTYPE":"opspilot","APPNAME":"console"}`
   - aigc 的 body: `{"ENV":"devops-opspilot","APPTYPE":"opspilot","APPNAME":"aigc"}`
   - 优先使用 `jenkins-hk/scripts/trigger-deploy-opspilot-webhook.ps1 -AppName <watch|console|aigc>`。
   - 不要为此发布路径使用浏览器点击、SSO 页面、`/job/deploy_opspilot/build` 或 `/job/deploy_opspilot/buildWithParameters`。
6. 报告：
   - 项目
   - 自动获取的 tag 及来源
   - GitLab commit/MR/merge 结果
   - Jenkins webhook HTTP 状态、`triggered` 值、resolved variables 和 queue item id

## 确认规则

- 用户要求发布单个 TK 项目，或未明确项目从而默认发布所有项目时，视为确认可以先自动查询目标项目 tag。
- 仍然要在任何 commit、push、MR 或 merge 前展示 GitLab diff。
- 对 webhook 发布路径，用户要求 release 单个项目，或未明确项目从而默认发布所有项目时，视为确认可以在 GitLab tag 状态正确后发送对应项目 webhook。
- 如果自动获取 tag 失败、为空或存在冲突，不要修改 Helm chart，也不要触发 Jenkins。

## 安全规则

- 仅在用户明确要求多项目，或用户未明确项目从而触发默认所有项目发布时，才编辑多个项目。
- 不要修改无关 YAML 字段或 helper image tag。
- 如果 GitLab tag 变更失败或未进入 `master`，不要部署。
- 不要编造 GitLab、gitlab-sre 或 Jenkins 凭据。
- 不要绕过 GitLab 受保护分支、审批、pipeline 或 Jenkins 权限规则。
- 不要在回复中暴露 token、密码、crumb、cookie 或 secret header。
