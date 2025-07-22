#### 1.构建Opspilot服务的镜像
```shell
#cd 项目代码下
cd /Users/opspilot/opspilot20250702

docker build -t docker.io/song1206/ops-watch:20250708-main-arm -f Dockerfile-harbor-arm .
docker build -t docker.io/song1206/ops-lookup:20250708-main-arm -f Dockerfile-harbor-arm .
docker build -t docker.io/song1206/ops-console:20250708-main-arm -f Dockerfile-arm .
docker build -t docker.io/song1206/ops-aigc:20250708-main-arm -f Dockerfile-arm .

docker push docker.io/song1206/ops-watch:20250708-main-arm
docker push docker.io/song1206/ops-lookup:20250708-main-arm
docker push docker.io/song1206/ops-console:20250708-main-arm
docker push docker.io/song1206/ops-aigc:20250708-main-arm
```

#### 2.通过脚本部署Opspilot及初始化数据源
```shell

sh install_opspilot.sh  # 一键安装

sh instert_datasource.sh # 初始化数据源

sh delete_opspilot.sh  # 一键卸载

```

#### 3.opsilot服务项目初始化配置
1. 登陆http://opspilot.simple.com/login     admin/#EDC4rfv


