```shell
helm package common/ --dependency-update=true

helm repo index --url https://songyanping.github.io/helm-chart/common ./common
```