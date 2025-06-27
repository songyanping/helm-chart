### Opspilot安装步骤
以下部署按默认配置安装，关于镜像仓库配置/持久化配置/服务暴露配置等，请自行修改。

#### 1.部署APM服务(Skywalking Server + ES&Kibana)
```shell
# 下载helm-chart代码进行修改及安装，支持不下载helm-chart代码，通过helm添加仓库方式安装
git clone https://github.com/songyanping/helm-chart.git

kubectl create ns skywalking

helm install elasticsearch middleware/elasticsearch --namespace skywalking 

helm install kibana middleware/kibana --namespace skywalking 

helm install skywalking middleware/skywalking --namespace skywalking
```

#### 2.App Agent(Skywalking agent)
##### 2.1后端java项目
1. 下载java agent(v9.1.0), 参考https://skywalking.apache.org/downloads
2. 以下是通过java -jar命令启动应用挂载skywalking-agent示例。(如果你的应用是部署在k8s中，需要将以下命令转换成k8s中启动命令)
```shell
tar -xzvf apache-skywalking-java-agent-9.1.0.tgz
cd ~/skywalking-agent
java -javaagent:./skywalking-agent.jar -Dskywalking.agent.service_name=prod@tpa::simple -Dskywalking.collector.backend_service=
skywalking-oap.skywalking.svc.cluster.local:11800 -jar app.jar
```

##### 2.2前端JavaScript项目
...

#### 3.部署Opspilot平台
```shell
kubectl create ns opspilot

helm install elasticsearch middleware/elasticsearch --namespace opspilot 

helm install kibana middleware/kibana --namespace opspilot

helm install postgresql middleware/postgresql --namespace opspilot

helm install casdoor middleware/casdoor --namespace opspilot

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

#### 4.扩容流程：
1. sky-es 扩容顺序：master、coordinator、ingest、data

2. skywalking: init + oap

3. （可选）opspilot-es：data；opspilot-exporter：稍扩cpu mem

#### 4.扩容示例
通过helm upgrade命令进行扩容，--set参数修改对应服务配置
```shell
// 修改预设资源规格
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resourcesPreset=medium

// 单独修改某个具体指标
helm upgrade elasticsearch middleware/elasticsearch --namespace skywalking --set master.resources.limits.cpu=350m
```