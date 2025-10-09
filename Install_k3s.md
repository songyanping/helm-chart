#### 一.Mac 通过multipass命令创建vm
```shell

multipass -v  #命令帮助

# 1.创建并启动主节点虚拟，资源根据实际情况分配
multipass launch --name master --cpus 4 --memory 6G --disk 50G

# 2.创建并启动第一个工作节点虚拟机
multipass launch --name node1 --cpus 16 --memory 24G --disk 100G
```

#### 二.创建k3s集群
```shell
# 在master节点上安装并启动K3s服务
multipass exec master -- /bin/bash -c "curl -sfL https://get.k3s.io | sh - && sudo systemctl enable k3s && sudo systemctl start k3s"

# 获取 K3s 服务的 token
TOKEN=$(multipass exec master -- sudo cat /var/lib/rancher/k3s/server/node-token)

# 获取主节点的IPv4地址
MASTER_IP=$(multipass info master | grep IPv4 | awk '{print $2}')

# 在第一个工作节点上安装K3s服务
multipass exec node1 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=$TOKEN sh -"

# 将k3s config文件拷贝至本地进行链接
/etc/rancher/k3s/k3s.yaml

# 验证K3s集群是否成功搭建
kubectl get node

```

#### 三.安装可能遇到的问题
1. curl -sfL https://get.k3s.io 网络问题k3s安装脚本下载不了，可以将本地k3s.sh复制到vm再执行
2. vm dns解析docker.io域名无法下载镜像，在vm的/etc/hosts 添加a记录：103.240.182.55  docker.io
   20.205.243.166 github.com
3. opspilot使用的是自定义域名，需要在本地添加a记录：/etc/hosts
   192.168.67.6 kibana.simple.com skywalking-ui.simple.com prometheus.simple.com opspilot.simple.com elasticsearch.simple.com skywalking-oap.simple.com
4. 原文档链接：https://juejin.cn/post/7384256110280556596