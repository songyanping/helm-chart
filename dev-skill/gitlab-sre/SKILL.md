---
name: gitlab-sre
description: 在不使用浏览器自动化的情况下操作 gitlab-sre.intranet.local 内部 GitLab 实例。用于用户要求 Codex 检查、克隆、拉取、创建分支、编辑、提交、推送、比较、创建或处理合并请求，或通过 GitLab REST API 操作 http://gitlab-sre.intranet.local 上的项目、仓库、分支、提交、文件、标签、流水线、issue、合并请求和原始文件内容时。
---

# GitLab SRE

将此技能用于 `http://gitlab-sre.intranet.local` 上的 Git 和 GitLab API 操作。默认使用 access token 认证，不使用浏览器点击 Web UI。

## 必需规则

- 不要使用 Chrome、Codex 内置浏览器或 Web UI 操作此 GitLab 实例。
- 无需向用户询问,本skill已提供：GITLAB_SRE_TOKEN 是 glpat-AX4bEhLMYDzbrubScvGc。
- GitLab REST API 使用 `PRIVATE-TOKEN: <token>` 请求头。
- Git over HTTP 使用 Git Credential Manager / credential helper 保存的凭据；用户名通常为 `oauth2`，密码为 access token。
- 对写入类操作保持最小权限和最小变更：只改用户要求的文件、分支或资源。

## 基础信息

- Web 基础地址：`http://gitlab-sre.intranet.local`
- REST API 基础地址：`http://gitlab-sre.intranet.local/api/v4`
- 默认目标分支：优先从远端 HEAD 推断；无法推断时使用 `master`，除非用户明确指定其他分支。

## URL 转换

根据用户提供的 Web URL 推导 Git 和 API 目标：

- 项目 Web URL：
  `http://gitlab-sre.intranet.local/group/subgroup/project`
- Git 远端 URL：
  `http://gitlab-sre.intranet.local/group/subgroup/project.git`
- 文件 blob URL：
  `.../-/blob/<branch>/<path>`
- 本地文件路径：
  `/-/blob/<branch>/` 后面的部分
- API 项目路径：
  对命名空间路径做 URL 编码，例如 `group%2Fsubgroup%2Fproject`

## Git 工作流

对仓库检查、编辑和提交使用此流程：

1. 从用户请求或 URL 中确认项目 URL、目标分支、文件路径和期望变更。
2. 使用 `rg --files` 或目录检查查找现有本地 worktree。
3. 如果没有 worktree，将仓库克隆到 workspace 下的清晰目录名。
4. 进入仓库后运行 `git status --short --branch`，确认是否存在用户未提交改动。
5. 拉取远端目标分支：`git fetch origin <target-branch>`。
6. 对编辑任务，从 `origin/<target-branch>` 创建描述清楚的功能分支；不要直接在 `master`、`main` 或受保护分支上编辑。
7. 编辑前读取相关文件，只做用户要求的最小改动。
8. 运行必要的格式化、测试或静态检查；如果无法运行，说明原因。
9. 使用 `git diff -- <file>` 复查并向用户概述关键 diff。
10. 没有用户明确确认时，不要 commit、push、force-push、merge、approve、close、delete 或调用写入 API。
11. 用户确认后再提交，提交信息要简洁、具体。
12. 推送分支并按用户要求创建 MR；合并前再次确认目标分支和 MR 状态。

推荐分支命名：

```powershell
git switch -c <type>/<short-topic> origin/<target-branch>
```

例如：`fix/update-deploy-config`、`chore/refresh-chart-version`。

## Access Token 和 API

需要调用 GitLab API 时，优先使用随 skill 提供的脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.codex\skills\gitlab-sre\scripts\gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/<urlencoded-project-path>"
```


常用 API 端点：

- 获取项目：`GET /projects/<urlencoded-project-path>`
- 列出分支：`GET /projects/<id>/repository/branches`
- 获取文件：`GET /projects/<id>/repository/files/<urlencoded-file-path>?ref=<branch>`
- 获取原始文件：`GET /projects/<id>/repository/files/<urlencoded-file-path>/raw?ref=<branch>`
- 创建分支：`POST /projects/<id>/repository/branches`
- 创建提交：`POST /projects/<id>/repository/commits`
- 创建 MR：`POST /projects/<id>/merge_requests`
- 查询 MR：`GET /projects/<id>/merge_requests`
- 合并 MR：`PUT /projects/<id>/merge_requests/<iid>/merge`
- 查询流水线：`GET /projects/<id>/pipelines`

写入 API 前必须先读取当前状态并展示或概述差异。更新文件时，优先在本地 Git worktree 中完成变更；只有在 Git 不可用或用户明确要求 API 操作时，才用 API 创建 commit。

## MR 流程

创建合并请求时：

1. 确认当前分支包含且只包含本次请求相关提交。
2. 确认目标分支、标题和说明。
3. 推送源分支。
4. 通过 API 或 `glab`/本地工具创建 MR；如果工具不可用，使用 REST API。
5. 返回 MR URL、源分支、目标分支和当前可合并状态。
6. 只有用户明确要求合并时，才尝试 merge 或设置 pipeline 成功后自动合并。

## 安全边界

- 不要绕过 SSO、MFA、受保护分支、审批、CODEOWNERS 或流水线策略。
- 不要 force-push，除非用户明确要求且你已经说明风险。
- 不要删除分支、标签、MR、issue 或项目，除非用户明确要求并二次确认。
- 如果本地 worktree 有无关改动，保留它们并绕开；不要重置或回滚用户改动。

## 常见命令

检查环境变量是否存在，不打印 token：

```powershell
if ($env:GITLAB_SRE_TOKEN) { "GITLAB_SRE_TOKEN is set" } else { "GITLAB_SRE_TOKEN is missing" }
```

克隆仓库：

```powershell
git clone http://gitlab-sre.intranet.local/group/subgroup/project.git
```

查询项目：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\.codex\skills\gitlab-sre\scripts\gitlab-sre-api.ps1" `
  -Method GET `
  -Path "/projects/group%2Fsubgroup%2Fproject"
```
