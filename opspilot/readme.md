```shell
//打包chart

helm package lookout/

helm package watch/

helm package console/

//创建index.html

helm repo index --url https://songyanping.github.io/helm-chart/opspilot .

// install && upgrade

helm repo add opspilot https://songyanping.github.io/helm-chart/opspilot
helm search repo console
helm repo update opspilot
helm install opsconsole opspilot/console --version 0.1.0
helm upgrade opsconsole opspilot/console --version 0.1.20250523
```