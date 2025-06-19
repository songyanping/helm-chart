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
helm install console opspilot/watch --version 0.1.20250606 --namespace opspilot
helm install console opspilot/console --version 0.1.20250606 --namespace opspilot
helm install console opspilot/lookout --version 0.1.20250606 --namespace opspilot
helm install console opspilot/aigc --version 0.1.20250606 --namespace opspilot
```

# Upgrade
```shell
helm repo update opspilot
helm repo update middleware
helm repo update common
helm upgrade console opspilot/console --version 0.1.20250606 --namespace opspilot
```

# Appendix
```shell
//打包chart
helm package lookout/ --dependency-update=true
helm package watch/  --dependency-update=true
helm package console/ --dependency-update=true
helm package aigc/ --dependency-update=true

helm package common-library/ --dependency-update=true

//创建index.html
helm repo index --url https://songyanping.github.io/helm-chart/opspilot .
helm repo index --url https://songyanping.github.io/helm-chart/middleware .
helm repo index --url https://songyanping.github.io/helm-chart/common .
```