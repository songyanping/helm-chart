```shell
//打包chart

helm package lookout/

helm package watch/

helm package console/

//创建index.html

helm repo index --url https://songyanping.github.io/helm-chart/opspilot .
```