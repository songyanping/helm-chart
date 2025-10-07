#!/bin/bash

# 定义版本变量
VERSION="1.0.0-arm"

# 创建命名空间
kubectl create ns opspilot
if [ $? -ne 0 ]; then
    echo "创建命名空间 opspilot 已存在"
fi

# 安装中间件服务
helm install elasticsearch middleware/elasticsearch --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 elasticsearch 失败"
    exit 1
fi

while true; do
    current_status=$(kubectl -n opspilot get pod elasticsearch-ingest-0 2>/dev/null |awk 'NR==2 {print $2}')
    # 检查状态是否为Running
    if [ "$current_status" == "1/1" ]; then
        echo "ES Pod已启动 状态 Running：$current_status"
        break  # 退出循环，执行下一步
    else
        echo "ES 安装中,当前状态 Running：$current_status"
        sleep 30  # 等待120秒后再次检查
    fi
done


helm install kibana middleware/kibana --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 kibana 失败"
    exit 1
fi

helm install redis middleware/redis --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 redis 失败"
    exit 1
fi

# 添加 Helm 仓库并更新
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
if [ $? -ne 0 ]; then
    echo "添加 Helm 仓库失败"
    exit 1
fi

helm repo update opspilot
if [ $? -ne 0 ]; then
    echo "更新 Helm 仓库失败"
    exit 1
fi

# 安装 Opspilot 平台组件
helm install watch opspilot/watch --version $VERSION --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 watch 失败"
    exit 1
fi

helm install console opspilot/console --version $VERSION --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 console 失败"
    exit 1
fi

helm install lookout opspilot/lookout --version $VERSION --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 lookout 失败"
    exit 1
fi


helm install aigc opspilot/aigc --version $VERSION --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 aigc 失败"
    exit 1
fi

helm install prometheus middleware/prometheus --namespace opspilot
if [ $? -ne 0 ]; then
    echo "安装 prometheus 失败"
    exit 1
fi

sleep 30
echo "所有组件安装完成"

kubectl get pod -n opspilot