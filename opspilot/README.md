### 1. 打包chart
```shell
helm package lookout/ --dependency-update=true
helm package watch/  --dependency-update=true
helm package console/ --dependency-update=true
helm package aigc/ --dependency-update=true
```
### 2. 创建index.html
```shell
helm repo index --url https://songyanping.github.io/helm-chart/opspilot .
```