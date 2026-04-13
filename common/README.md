### 1.修改common包之后需重新打包及更新index.html 
```shell
cd  common

helm package ./opspilot-common --dependency-update=true

helm repo index --url https://songyanping.github.io/helm-chart/common .
# 验证：https://songyanping.github.io/helm-chart/common/index.yaml
```

### 2.推送仓库
```shell
git push
```