#### 一.Opspilot项目打镜像
```shell
cd /Users/opspilot/opspilot20250702/code # 进入代码目录
cd cd opswatch 
git status  # 查看分支及状态，git checkout main 切换分支
git pull    # 拉取新代码
docker build -t docker.io/song1206/ops-watch:v20251009-dev -f Dockerfile-harbor-arm . # 构建镜像
docker push docker.io/song1206/ops-watch:v20251009-dev # 推送镜像

# 其他项目省略构建镜像过程一致，省略......
```

#### 二.Opspilot一键安装
```shell
sh 1-install_opspilot.sh
```

#### 三.Opspilot数据初始化
```shell
sh 2-insert_datasource.sh  #导入数据源

sh 3-insert_aigc.sh  #导入AIGC配置
```

#### 四.Opspilot一键删除

```shell
sh 4-delete_opspilot.sh
```

#### 登陆opspilot平台

1. http://opspilot.simple.com/login     admin/#EDC4rfv
2. http://prometheus.simple.com
3. http://kibana.simple.com
4. http://skywalking-ui.simple.com