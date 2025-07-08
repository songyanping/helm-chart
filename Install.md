### Opspilot安装优化内容

#### 1.使用helm安装方式
1. 将opspilot项目部署由manifests(资源清单)方式修改为helm chart方式，将charts推送到仓库中，方便安装。
2. 通过helm chart方式统一控制应用版本

```shell
helm repo list
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
helm repo update opspilot 
helm search repo console
helm install console opspilot/watch --version 1.0.0-arm --namespace opspilot --set resourcesPreset=medium
```

#### 2.使用公共库定义资源规则和经验值
1. 公共库（opspilot-common）预设3个资源规格（大中小），方便在扩缩容时候直接使用
2. 公共库（opspilot-common）预设经验值skywalking线程数、heapSize等等
```yaml

{{- define "elasticsearch.master.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "heapSize" "512m"
      "requests" (dict "cpu" "200m" "memory" "1Gi")
      "limits" (dict "cpu" "200m" "memory" "1Gi")
   )
  "medium" (dict
      "replicaCount" 2
      "heapSize" "1024m"
      "requests" (dict "cpu" "300m" "memory" "2Gi")
      "limits" (dict "cpu" "300m" "memory" "2Gi")
   )
  "large" (dict
      "replicaCount" 3
      "heapSize" "2048m"
      "requests" (dict "cpu" "500m" "memory" "4Gi")
      "limits" (dict "cpu" "500m" "memory" "4Gi")
   )
 }}

```

#### 3.Opspilot构建镜像

#### 4.脚本部署Opspilot
```shell

sh install_opspilot.sh  # 一键安装

sh delete_opspilot.sh  # 一键卸载

```


```shell
# 脚本详情
kubectl create ns opspilot
helm install elasticsearch middleware/elasticsearch --namespace opspilot 
helm install kibana middleware/kibana --namespace opspilot
helm install redis middleware/redis --namespace opspilot
helm install prometheus middleware/prometheus --namespace opspilot

# 通过helm添加仓库方式安装
helm repo list
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
helm repo update opspilot 
helm search repo console

helm install watch opspilot/watch --version 1.0.0-arm --namespace opspilot --set resourcesPreset=medium
helm install console opspilot/console --version 1.0.0-arm --namespace opspilot
helm install lookout opspilot/lookout --version 1.0.0-arm --namespace opspilot
helm install aigc opspilot/aigc --version 1.0.0-arm --namespace opspilot
```

#### 5.opsilot服务项目初始化配置


#### 6.扩容示例
通过helm upgrade命令进行扩容，--set参数修改对应服务配置
```shell
// 修改预设资源规格
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resourcesPreset=medium

// 单独修改某个具体指标
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resources.limits.cpu=2000m
```