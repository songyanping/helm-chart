### Opspilot安装步骤

#### 3.部署Opspilot平台
```shell
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

helm install watch opspilot/watch --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install console opspilot/console --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install lookout opspilot/lookout --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install aigc opspilot/aigc --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
```


#### 4.扩容示例
通过helm upgrade命令进行扩容，--set参数修改对应服务配置
```shell
// 修改预设资源规格
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resourcesPreset=medium

// 单独修改某个具体指标
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resources.limits.cpu=350m
```