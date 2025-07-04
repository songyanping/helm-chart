#!/bin/bash

# 定义命名空间
NAMESPACE="opspilot"

# 卸载 Opspilot 平台组件
helm uninstall watch -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 watch 失败"
fi

helm uninstall console -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 console 失败"
fi

helm uninstall lookout -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 lookout 失败"
fi

# 卸载中间件服务
helm uninstall elasticsearch -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 elasticsearch 失败"
fi

helm uninstall kibana -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 kibana 失败"
fi

helm uninstall redis -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 redis 失败"
fi

helm uninstall prometheus -n $NAMESPACE
if [ $? -ne 0 ]; then
    echo "卸载 prometheus 失败"
fi

# 删除命名空间（根据需要可选）
kubectl delete namespace $NAMESPACE
if [ $? -ne 0 ]; then
    echo "删除命名空间 $NAMESPACE 失败"
fi

echo "所有组件已成功卸载并清理完成"
