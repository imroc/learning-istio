---
title: 应用未监听 0.0.0.0 导致连接异常
type: book
date: "2021-03-25"
weight: 60
---

## 背景

istio 要求应用提供服务时监听 `0.0.0.0`，因为 127 和 Pod IP 地址都被 envoy 占用了。有些应用启动时没有监听 `0.0.0.0` 或 `::` 的地址，就会导致无法正常通信，参考 [Application Bind Address](https://istio.io/latest/docs/ops/deployment/requirements/#application-bind-address) 。

## 案例

### zookeeper

当 zookeeper 部署到集群中时，默认监听的 Pod IP，会导致 zookeeper 各个实例之间无法正常通信。

解决方案: 在 zk 的配置文件中键入 [quorumListenOnAllIPs=true](https://zookeeper.apache.org/doc/r3.5.7/zookeeperAdmin.html) 的配置 ( 参考 [istio官方文档](https://istio.io/v1.8/faq/applications/#zookeeper) ) 
