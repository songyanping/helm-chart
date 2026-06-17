---
name: jenkins-hk
description: 触发 jenkins-ecomm-hk.intranet.local 上内部 Jenkins OpsPilot deploy_opspilot Generic Webhook 端点。当 Codex 需要通过发送包含 ENV、APPTYPE 和 APPNAME 的 webhook payload，经 Jenkins 发布或部署 OpsPilot watch、console 或 aigc 时使用。
---

# Jenkins HK

仅将此 skill 用于 `http://jenkins-ecomm-hk.intranet.local/` 上的 OpsPilot `deploy_opspilot` Jenkins webhook。

不要为此发布路径使用浏览器页面或 Jenkins job build URL。

## Webhook 发布

向以下地址发送 `POST` 请求：

```text
http://jenkins-ecomm-hk.intranet.local/generic-webhook-trigger/invoke?token=<webhook-token>
```

必需 header：

```text
Content-Type: application/json
```

默认 payload：

```json
{"ENV":"devops-opspilot","APPTYPE":"opspilot","APPNAME":"watch"}
```

watch 使用 `APPNAME:"watch"`，console 使用 `APPNAME:"console"`，aigc 使用 `APPNAME:"aigc"`。除非用户明确要求修改，否则保持 `ENV` 和 `APPTYPE` 不变。

不要在此 skill 中存储 webhook token。从运行时参数或 `JENKINS_DEPLOY_OPSPILOT_WEBHOOK_TOKEN` 读取它。
helper 脚本按 Process、User、Machine 环境作用域解析 token。

## Helper 脚本

优先使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "dev-skill/jenkins-hk/scripts/trigger-deploy-opspilot-webhook.ps1" -AppName watch
```

对于 console：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "dev-skill/jenkins-hk/scripts/trigger-deploy-opspilot-webhook.ps1" -AppName console
```

对于 aigc：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "dev-skill/jenkins-hk/scripts/trigger-deploy-opspilot-webhook.ps1" -AppName aigc
```

如果当前进程看不到新配置的 token，不要在脚本调用周围内联 shell 变量。重新运行上面的 helper 命令；脚本本身会读取 User 和 Machine 环境作用域。

Jenkins 响应应包含：

- `triggered: true`
- `resolvedVariables.APPNAME`
- queue item 的 `id`
- queue item 的 `url`

向用户报告这些字段。

## 连通性检查

如果 Jenkins 不可达，运行：

```powershell
.\scripts\test-connection.ps1
```

报告 DNS、TCP 端口 80 或 HTTP 连通性是否失败。

## 安全

- 每个用户发布请求只发送一次 webhook。
- 除非用户明确要求，否则不要更改 `ENV`、`APPTYPE`、webhook token 或目标 URL。
- 不要打印 webhook token 或 secret header。
