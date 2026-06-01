# Agent Helm Chart Design

## Goal

Add an independent `opspilot/agent` Helm chart to replace the effective
Kubernetes resources currently described in `opspilot/ops-agent`.

The chart deploys the OpsPilot agent service and its `cc-connect` companion in
one Pod. It preserves the current runtime behavior while exposing environment
specific settings through `values.yaml`.

## Scope

The chart manages:

- One Deployment with two containers: `agent-service` and `cc-connect`.
- One LoadBalancer Service exposing ports `8080` and `1455`.
- One ConfigMap containing the `cc-connect` TOML configuration.
- One Secret containing the Feishu application credentials.
- One ServiceAccount, following the existing OpsPilot chart convention.

The chart does not create or mount the existing `agent-memories-pvc`. PVC
support is intentionally deferred because the current Deployment does not use
it.

The source files under `opspilot/ops-agent` remain reference manifests. The new
chart is created under `opspilot/agent`.

## Namespace Strategy

Templates do not hard-code `metadata.namespace`. Kubernetes resources are
installed into the Helm release namespace. For the current environment, the
installation command is:

```shell
helm install agent opspilot/agent --namespace aiops --create-namespace
```

## Chart Structure

```text
opspilot/agent/
  Chart.yaml
  values.yaml
  .helmignore
  templates/
    _helpers.tpl
    configmap.yaml
    deployment.yaml
    secret.yaml
    service.yaml
    serviceaccount.yaml
```

The chart depends on `opspilot-common` version `1.0.3`, matching the current
OpsPilot application charts.

## Values Model

`values.yaml` uses explicit sections for the two containers rather than a
generic container array:

```yaml
replicaCount: 1

imagePullSecrets:
  - name: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com

agent:
  image:
    repository: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com/sre/ops-agent
    tag: v202605291027-25c1c8f3-dev
    pullPolicy: IfNotPresent
  securityContext: {}
  resources: {}

ccConnect:
  image:
    repository: amway-devops-registry-vpc.cn-shenzhen.cr.aliyuncs.com/sre/cc-connect
    tag: v202605290821-67aa1cab-cc
    pullPolicy: IfNotPresent
  credentials:
    # Defaults are copied from the reference Secret during implementation.
    feishuAppIdBase64: redacted-in-design-document
    feishuAppSecretBase64: redacted-in-design-document
  config: |
    # Default TOML is copied from the reference ConfigMap during implementation.
  resources: {}

service:
  type: LoadBalancer
  annotations: {}
  ports: {}
```

Defaults preserve the resource requests and limits, Service annotations,
container security context, ports, image pull secret, mounts, and ConfigMap
content from the reference manifests.

## Deployment Design

The Deployment creates a Pod labeled with the chart selector labels and
contains:

### `agent-service`

- Exposes container port `8080`.
- Uses the current root-compatible security context:
  `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, and
  `runAsNonRoot: false`.
- Mounts `matplotlib-cache` at `/app/.matplotlib`.
- Mounts `workspace` at `/app/workspace`.

### `cc-connect`

- Exposes named container port `cc-connect` on `1455`.
- Reads `FEISHU_APP_ID` and `FEISHU_APP_SECRET` from the generated Secret.
- Mounts `cc-connect-data` at `/data`.
- Mounts the generated ConfigMap key `config.toml` at
  `/etc/cc-connect/config.toml`.

The Pod defines three `emptyDir` volumes: `matplotlib-cache`, `workspace`, and
`cc-connect-data`.

## ConfigMap And Secret

The ConfigMap stores `ccConnect.config` as `config.toml`. The default TOML
matches `opspilot/ops-agent/k8s-config.yaml`.

The Secret stores Feishu credentials supplied through `values.yaml`. The
credential values remain Base64-encoded strings, matching the existing Secret,
and the template places them under the Secret `data` field without performing
an additional encoding step. The default values are copied from the reference
Secret so the chart can replace the current manifests without an additional
configuration step. This is a deliberate short-term choice requested for the
current deployment workflow. Base64 is not encryption: these credentials will
be present in Git and will also be stored in Helm release history. A later
improvement should support referencing an existing Secret.

## Service Design

The Service selects the Deployment Pod and exposes:

- `http`: service port `8080`, targeting container port `8080`.
- `cc-connect`: service port `1455`, targeting named container port
  `cc-connect`.

The default type is `LoadBalancer`. Default annotations preserve the existing
Alibaba Cloud intranet load balancer settings.

## Validation

Implementation validation covers:

1. Non-template YAML parsing.
2. Static assertions that the chart contains the expected Deployment,
   ConfigMap, Secret, Service, two containers, ports, mounts, volumes, and
   namespace-neutral templates.
3. `helm lint` and `helm template` when a Helm binary is available.

The local environment currently does not have a `helm` binary, so Helm-based
validation may require installing Helm or running the checks in CI.
