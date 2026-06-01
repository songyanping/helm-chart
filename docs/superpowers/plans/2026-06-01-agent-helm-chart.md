# Agent Helm Chart Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `opspilot/agent`, an installable Helm chart that replaces the effective resources in `opspilot/ops-agent` with one two-container Deployment and its supporting Service, ConfigMap, Secret, and ServiceAccount.

**Architecture:** Model `agent-service` and `cc-connect` explicitly in `values.yaml` and render both containers in one Deployment. Keep namespace selection release-scoped, generate the ConfigMap and Secret from values, preserve the existing LoadBalancer behavior, and defer the unused PVC.

**Tech Stack:** Helm 3, Kubernetes YAML, Go templates, Ruby YAML parser, shell assertions.

---

### Task 1: Verify The Missing Chart Fails

**Files:**
- Reference: `opspilot/ops-agent/k8s-deploy.yaml`
- Reference: `opspilot/ops-agent/k8s-config.yaml`
- Reference: `opspilot/ops-agent/k8s-service.yaml`
- Reference: `opspilot/ops-agent/secret.yaml`

- [ ] **Step 1: Run the failing Helm lint check**

Run:

```bash
/Users/even/bin/helm lint opspilot/agent
```

Expected: FAIL because `opspilot/agent/Chart.yaml` does not exist.

- [ ] **Step 2: Run the failing Helm render check**

Run:

```bash
/Users/even/bin/helm template agent opspilot/agent --namespace aiops
```

Expected: FAIL because the chart directory does not exist.

### Task 2: Create Chart Metadata And Values

**Files:**
- Create: `opspilot/agent/.helmignore`
- Create: `opspilot/agent/Chart.yaml`
- Create: `opspilot/agent/values.yaml`
- Create: `opspilot/agent/charts/opspilot-common-1.0.3.tgz`

- [ ] **Step 1: Create `.helmignore`**

Use the same ignore rules as `opspilot/aigc/.helmignore`.

- [ ] **Step 2: Create `Chart.yaml`**

Create an application chart named `agent`, version `0.1.0`, with
`appVersion: "1.0.0"` and the existing OpsPilot dependency:

```yaml
dependencies:
  - name: opspilot-common
    repository: https://songyanping.github.io/helm-chart/common
    tags:
      - opspilot-common
    version: 1.0.3
```

- [ ] **Step 3: Create `values.yaml`**

Define:

```yaml
replicaCount: 1
nameOverride: "agent-service"
fullnameOverride: "agent-service"
imagePullSecrets:
  - name: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com
serviceAccount:
  create: true
  annotations: {}
  name: ""
podAnnotations: {}
podSecurityContext: {}
agent:
  image:
    repository: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com/sre/ops-agent
    tag: "v202605291027-25c1c8f3-dev"
    pullPolicy: IfNotPresent
  securityContext:
    readOnlyRootFilesystem: false
    runAsUser: 0
    runAsGroup: 0
    runAsNonRoot: false
  resources:
    limits:
      cpu: "2000m"
      memory: "4096Mi"
    requests:
      cpu: "500m"
      memory: "1024Mi"
ccConnect:
  image:
    repository: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com/sre/cc-connect
    tag: "v202605290821-67aa1cab-cc"
    pullPolicy: IfNotPresent
  credentials:
    feishuAppIdBase64: "Y2xpX2E5NDc2OTQ3OTIyNGRiZDg="
    feishuAppSecretBase64: "TDRvYkdUYjNrWWVWUndxMkh3Y1d1Y1FZRm1EU2p4dWw="
  resources:
    limits:
      cpu: "500m"
      memory: "1024Mi"
    requests:
      cpu: "250m"
      memory: "512Mi"
  config: |
    language = "zh"
    data_dir = "/data/cc-connect"
service:
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/alibaba-cloud-loadbalancer-address-type: intranet
    service.beta.kubernetes.io/alibaba-cloud-loadbalancer-instance-charge-type: PayBySpec
  ports:
    http: 8080
    ccConnect: 1455
nodeSelector: {}
tolerations: []
affinity: {}
```

Copy the complete TOML body from `opspilot/ops-agent/k8s-config.yaml`, not only
the abbreviated lines shown above.

- [ ] **Step 4: Vendor the existing common dependency**

Run:

```bash
mkdir -p opspilot/agent/charts
cp opspilot/aigc/charts/opspilot-common-1.0.3.tgz opspilot/agent/charts/
```

### Task 3: Create Helm Templates

**Files:**
- Create: `opspilot/agent/templates/_helpers.tpl`
- Create: `opspilot/agent/templates/serviceaccount.yaml`
- Create: `opspilot/agent/templates/configmap.yaml`
- Create: `opspilot/agent/templates/secret.yaml`
- Create: `opspilot/agent/templates/deployment.yaml`
- Create: `opspilot/agent/templates/service.yaml`

- [ ] **Step 1: Create naming helpers**

Copy the established helper structure from `opspilot/aigc/templates/_helpers.tpl`
and rename the template prefix from `aigc` to `agent`.

- [ ] **Step 2: Create the ServiceAccount**

Render a ServiceAccount only when `.Values.serviceAccount.create` is true. Use
`agent.serviceAccountName`, chart labels, and configurable annotations.

- [ ] **Step 3: Create the ConfigMap and Secret**

Render:

```yaml
data:
  config.toml: |
{{ .Values.ccConnect.config | indent 4 }}
```

and:

```yaml
data:
  FEISHU_APP_ID: {{ .Values.ccConnect.credentials.feishuAppIdBase64 | quote }}
  FEISHU_APP_SECRET: {{ .Values.ccConnect.credentials.feishuAppSecretBase64 | quote }}
```

- [ ] **Step 4: Create the two-container Deployment**

Render both containers, their ports, security context, resources, Secret-backed
environment variables, mounts, three `emptyDir` volumes, scheduling settings,
image pull secrets, and ServiceAccount. Do not add `metadata.namespace`, PVC
resources, or `/tmp/memories` mounts.

- [ ] **Step 5: Create the Service**

Render a configurable Service with existing Alibaba Cloud annotations and both
ports. Target `8080` directly for `http` and named port `cc-connect` for the
companion.

### Task 4: Run Helm And Static Validation

**Files:**
- Verify: `opspilot/agent`

- [ ] **Step 1: Parse non-template YAML**

Run:

```bash
ruby -e 'require "yaml"; %w[opspilot/agent/Chart.yaml opspilot/agent/values.yaml].each { |f| YAML.load_file(f); puts "ok #{f}" }'
```

Expected: both files print with `ok`.

- [ ] **Step 2: Lint the chart**

Run:

```bash
/Users/even/bin/helm lint opspilot/agent
```

Expected: `1 chart(s) linted, 0 chart(s) failed`.

- [ ] **Step 3: Render the chart**

Run:

```bash
/Users/even/bin/helm template agent opspilot/agent --namespace aiops > /tmp/agent-rendered.yaml
```

Expected: exit code `0`.

- [ ] **Step 4: Assert replacement behavior**

Run:

```bash
rg -n 'kind: (Deployment|Service|ConfigMap|Secret|ServiceAccount)|name: agent-service|name: cc-connect|containerPort: 8080|containerPort: 1455|FEISHU_APP_ID|FEISHU_APP_SECRET|mountPath: /app/.matplotlib|mountPath: /app/workspace|mountPath: /data|mountPath: /etc/cc-connect/config.toml|type: LoadBalancer' /tmp/agent-rendered.yaml
```

Expected: each required resource and runtime setting appears.

- [ ] **Step 5: Assert deferred behavior is absent**

Run:

```bash
if rg -n 'namespace: aiops|PersistentVolumeClaim|agent-memories-pvc|/tmp/memories' opspilot/agent/templates /tmp/agent-rendered.yaml; then exit 1; fi
```

Expected: exit code `0` with no output.

- [ ] **Step 6: Check whitespace**

Run:

```bash
git diff --check
```

Expected: exit code `0`.

### Task 5: Review And Commit The Chart

**Files:**
- Review: `opspilot/agent`

- [ ] **Step 1: Review changed files**

Run:

```bash
git status --short
git diff --stat
git diff -- opspilot/agent
```

Confirm that `.DS_Store` files and the reference `opspilot/ops-agent` directory
remain untracked and unstaged.

- [ ] **Step 2: Stage only the new chart**

Run:

```bash
git add opspilot/agent
git status --short
```

- [ ] **Step 3: Commit**

Run:

```bash
git commit -m "feat: add ops agent helm chart"
```

