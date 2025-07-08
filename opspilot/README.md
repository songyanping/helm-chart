# Install
```shell
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
helm repo add middleware https://songyanping.github.io/helm-chart/middleware

helm repo update opspilot
helm repo update middleware

helm search repo console
helm search repo middleware

kubectl create ns opspilot
kubectl create ns skywalking
helm install console opspilot/watch --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install console opspilot/console --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install console opspilot/lookout --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium
helm install console opspilot/aigc --version 0.1.20250606 --namespace opspilot --set resourcesPreset=medium

# debug 输出
helm install lookout  --debug .
```

# Upgrade
```shell
helm repo update opspilot
helm repo update middleware
helm repo update common
helm upgrade console opspilot/watch --version 0.1.20250606 --namespace opspilot --dependency-update=true
helm upgrade console opspilot/console --version 0.1.20250606 --namespace opspilot --dependency-update=true
helm upgrade console opspilot/lookout --version 0.1.20250606 --namespace opspilot --dependency-update=true
helm upgrade console opspilot/aigc --version 0.1.20250606 --namespace opspilot --dependency-update=true
```

# Appendix

1. 打包chart
```shell
helm package lookout/ --dependency-update=true
helm package watch/  --dependency-update=true
helm package console/ --dependency-update=true
helm package aigc/ --dependency-update=true

helm package opspilot-common/ --dependency-update=true
```
2. 创建index.html
```shell
helm repo index --url https://songyanping.github.io/helm-chart/opspilot .
helm repo index --url https://songyanping.github.io/helm-chart/middleware .
helm repo index --url https://songyanping.github.io/helm-chart/common .
```