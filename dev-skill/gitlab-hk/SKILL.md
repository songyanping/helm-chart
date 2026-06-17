---
name: gitlab-hk
description: 在不使用浏览器自动化的情况下操作 gitlab-hk.intranet.local 内部 GitLab 实例。当用户要求 Codex 检查、克隆、编辑、提交、推送、比较、创建分支，或对 http://gitlab-hk.intranet.local 上的仓库、文件、提交、分支、合并请求或原始文件内容调用 GitLab API 时使用。
---

# GitLab HK

将此技能用于 `http://gitlab-hk.intranet.local` 上的非浏览器操作。

## 必需方法

不要对此 GitLab 实例使用 Chrome、Codex 内置浏览器或 Web UI 点击。

优先按以下顺序处理：

不要在此技能中存储真实密码或 token。只使用以下凭据来源：

1. Git 操作：使用已经为 `gitlab-hk.intranet.local` 配置好的 Git credential helper / Git Credential Manager。
2. GitLab REST API 操作：只使用 `GITLAB_HK_TOKEN`。从 Process、User 或 Machine 环境作用域读取。

GITLAB的Token为: xKGKbQssfUVhLvPwQdyf

如果凭据缺失或被拒绝，停止并请用户为 Git 命令配置 Git credential helper，或为 API 命令配置 `GITLAB_HK_TOKEN`。不要要求用户在聊天中粘贴密码或 token。

## URL 转换

对于 GitLab Web URL，推导 Git 和 API 目标：

- Web 项目 URL：
  `http://gitlab-hk.intranet.local/group/subgroup/project`
- Git 远端 URL：
  `http://gitlab-hk.intranet.local/group/subgroup/project.git`
- 文件 blob URL：
  `.../-/blob/<branch>/<path>`
- 本地文件路径：
  `/-/blob/<branch>/` 之后的部分
- API 项目路径：
  对命名空间路径做 URL 编码，例如 `sre%2Fopspilot%2Fhelm-charts%2Fopspilot-chart`

## Git 工作流

对文件编辑使用此工作流：

1. 从用户的 URL 或请求中确认或推断项目 URL、分支、文件路径和请求的变更。
2. 使用 `rg --files` 或目录检查查找现有本地 worktree。
3. 如果没有 worktree，将仓库克隆到 workspace 中。
4. 拉取 `origin master`。
5. 从 `origin/master` 创建一个描述清晰的功能分支；不要直接编辑本地 `master`。
6. 编辑前检查当前文件。
7. 只编辑请求的行或字段。
8. 运行 `git diff -- <file>` 并向用户展示相关 diff。
9. 在提交、推送、创建 MR 或合并前要求明确确认。
10. 仅在确认后使用简洁消息提交。
11. 运行 `scripts/push-and-merge.ps1`，用一条命令推送当前分支、创建或复用目标为 `master` 的 MR，并尝试自动合并。
12. 如果合并成功，拉取 `origin master` 并验证目标分支包含请求的变更。如果合并受阻，报告确切的阻塞原因和 MR URL。

## 主分支策略

除非用户指定其他分支，否则将 `master` 作为 OpsPilot chart 仓库的默认目标分支。

编辑前，从当前远端 `master` 创建本地功能分支：

```powershell
git fetch origin master
git switch -c <feature-branch> origin/master
```

如果当前分支包含未合并的用户工作，不要 reset 或丢弃它。询问用户如何继续。

## 合并请求自动合并

在用户已经确认 diff 并希望结果合并到 `master` 后，使用此工作流：

1. 创建描述清晰的分支名，例如 `update-watch-tag-main-test`。
2. 确保已确认的提交在该分支上。
3. 从此技能目录运行 `scripts/push-and-merge.ps1`。
4. 脚本会推送分支，创建或复用目标为 `master` 的 MR，然后尝试合并。
5. 如果 MR 不能立即合并，并且 GitLab 支持，脚本会用 merge-on-pipeline-success 重试。
6. 将已合并的 MR URL、等待自动合并状态或阻塞原因发送给用户。


示例：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "dev-skill/gitlab-hk/scripts/push-and-merge.ps1" `
  -SourceBranch "<feature-branch>" `
  -TargetBranch "master" `
  -Title "<short title>"
```

仅当分支已经推送且不需要重试推送时，才直接使用 `merge-request.ps1`。

## REST API 工作流

仅当 Git 不可用，或用户要求基于 API 的操作时，才使用 GitLab API。

基础 URL：

`http://gitlab-hk.intranet.local/api/v4`

设置了 `GITLAB_HK_TOKEN` 时使用 token 认证：

```powershell
$headers = @{ "PRIVATE-TOKEN" = $env:GITLAB_HK_TOKEN }
```

常用端点：

- 获取项目：`GET /projects/<urlencoded-project-path>`
- 获取文件元数据/内容：`GET /projects/<id>/repository/files/<urlencoded-file-path>?ref=<branch>`
- 更新文件：`PUT /projects/<id>/repository/files/<urlencoded-file-path>`

对于更新文件请求，包含 `branch`、`content` 和 `commit_message`。先获取当前文件，在本地应用最小变更，然后在发送 PUT 请求前展示 diff。

## 安全规则

- 没有用户明确确认时，不要 commit、push、force-push、merge、approve、close、delete，或调用写 API。用户提出“merge it”、“auto-merge” 或 “merge to master”等请求时，视为确认可以为已经审阅过的 diff 创建并合并 MR。
- 不要对此 GitLab 实例使用浏览器自动化。
- 不要编辑无关文件。
- 除非用户要求两者都改，否则不要同时修改源文件和生成文件。
- 不要绕过权限、2FA、SSO、受保护分支策略或审批流程。
- 不要在回复、diff、日志、命令输出摘要或技能文件中暴露凭据。
- 如果密码或 token 意外可见，停止并询问用户如何轮换或处理。

## 常用仓库

- OpsPilot chart 仓库：
  `http://gitlab-hk.intranet.local/sre/opspilot/helm-charts/opspilot-chart.git`
