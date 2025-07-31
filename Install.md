#### 1.部署Skywalking APM
```shell
git clone git@github.com:songyanping/helm-chart.git
git checkout tw

cd helm-chart

kubectl create ns skywalking

helm install elasticsearch middleware/elasticsearch --namespace skywalking
helm install kibana middleware/kibana --namespace skywalking
helm install skywalking middleware/skywalking --namespace skywalking
```

#### 2.部署Opspilot
```shell
cd helm-chart

kubectl create ns opspilot

helm install elasticsearch middleware/elasticsearch --namespace opspilot 

helm install kibana middleware/kibana --namespace opspilot

helm install redis middleware/redis --namespace opspilot

helm install postgresql middleware/postgresql --namespace opspilot

helm install casdoor middleware/casdoor --namespace opspilot

helm install prometheus middleware/prometheus --namespace opspilot

# 通过本地helm仓库方式安装
helm install watch opspilot/watch --namespace opspilot
helm install console opspilot/console --namespace opspilot
helm install lookout opspilot/lookout --namespace opspilot
helm install aigc opspilot/aigc --namespace opspilot
```

#### 4.更新/扩容示例
通过helm upgrade命令进行扩容，--set参数修改对应服务配置
```shell
# 修改预设资源规格
helm upgrade watch opspilot/watch --namespace opspilot --set server.resourcesPreset=medium

helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resourcesPreset=medium

# 单独修改某个具体指标
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resources.limits.cpu=1000m
```


#### 5.不需要clone代码，通过添加远程helm chart仓库方式安装示例
```shell
# 通过helm添加仓库方式安装
helm repo list
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
helm repo update opspilot 
helm search repo console

helm install watch opspilot/watch --version v20250730 --namespace opspilot
helm install console opspilot/console --version v20250730 --namespace opspilot
helm install lookout opspilot/lookout --version v20250730 --namespace opspilot
helm install aigc opspilot/aigc --version v20250730 --namespace opspilot
```