```shell

//打包chart
helm package lookout/ --dependency-update=true

helm package watch/  --dependency-update=true

helm package console/ --dependency-update=true

helm package aigc/ --dependency-update=true

helm package common-library/ --dependency-update=true

//创建index.html
helm repo index --url https://songyanping.github.io/helm-chart/opspilot .

// install && upgrade
helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot

helm repo update opspilot

helm search repo console

helm install console opspilot/console --version 0.1.20250606 --namespace opspilot
helm upgrade console opspilot/console --version 0.1.20250606 --namespace opspilot
```