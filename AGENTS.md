# AGENTS.md

本文件是本仓库内 Codex/Agent 协作的项目规范。除非用户明确覆盖，所有自动化修改都应遵守这里的约定。

## 项目概览

- 这是 Helm chart 仓库，主要包含 `middleware/` 和 `opspilot/` 两组 chart。
- `middleware/` 存放基础组件 chart，例如 `elasticsearch`、`kibana`、`mysql`、`nginx`、`prometheus`、`redis`、`skywalking` 等。
- `opspilot/` 存放 OpsPilot 相关 chart，例如 `agent`、`aigc`、`console`、`watch` 等。
- 根目录脚本 `install_opspilot.sh`、`delete_opspilot.sh` 用于安装和卸载示例流程，修改前要确认命名空间、release 名称和 chart 路径是否仍然匹配。
- `dev-skill/` 仅用于本项目内的开发辅助 skill、脚本和 agent 配置，不应混入 Helm chart 运行时资源。

## Skill 读取限制

- Agent 如需读取、使用或参考 skill，只能读取本仓库 `dev-skill/` 目录中的内容。
- 不要读取、加载或引用 `dev-skill/` 之外的 skill 文件、全局 skill 缓存或用户主目录中的 skill。
- 如果任务需要某个 skill，但 `dev-skill/` 中不存在对应内容，应向用户说明缺失情况，并在不读取外部 skill 的前提下继续使用普通项目上下文处理。
- `dev-skill/` 中的脚本可作为项目自动化辅助使用；执行前先阅读对应 `SKILL.md` 和脚本内容，确认不会影响非目标环境。

## 修改原则

- 保持变更聚焦：只修改与用户请求直接相关的 chart、values、模板、脚本或文档。
- 不要重排无关 YAML 字段，不要批量格式化无关文件，避免制造难以审查的 diff。
- 修改 chart 时优先沿用当前 chart 的命名、标签、selector、helpers、values 层级和模板风格。
- 涉及镜像、tag、资源规格、端口、存储、探针、ingress、serviceAccount、RBAC 等运行时行为时，要同步检查 `values.yaml` 与 `templates/` 是否一致。
- 不要提交敏感信息，包括 kubeconfig、token、密码、私钥、内网凭据、真实生产连接串等。

## Helm 规范

- 每个 chart 的 `Chart.yaml`、`values.yaml`、`templates/` 应保持一致，新增 values 必须在模板中有明确用途。
- 模板中尽量使用 chart 已有 helper 和命名规则，不随意引入新的 label 或 annotation 体系。
- 修改依赖 chart 时，检查 `charts/`、`Chart.yaml` dependency、README 示例和安装命令是否需要同步。
- 对 Kubernetes API 版本、资源类型、字段名称保持谨慎，避免使用目标集群不支持的字段。
- values 默认值应尽量可本地渲染，不依赖必须手工注入的隐藏参数。

## 验证要求

- 修改 chart 后，至少对受影响 chart 执行：
  - `helm lint <chart-path>`
  - `helm template <release-name> <chart-path> --namespace <namespace>`
- 涉及依赖时使用 `--dependency-update` 或先执行 `helm dependency update <chart-path>`。
- 修改安装/卸载脚本后，至少做 shell 语法检查；如果当前环境不可执行，应在回复中说明未执行原因。
- 如果无法运行 Helm、kubectl 或 shell 验证，要明确告诉用户原因和剩余风险。

## Git 与协作

- 开始修改前先查看工作区状态，识别已有未提交变更。
- 不要回滚、覆盖或清理用户已有改动，除非用户明确要求。
- 新增文件放在最小必要位置；项目级规范文件放根目录。
- 回复用户时简要说明改了什么、验证了什么、哪些验证未运行。
