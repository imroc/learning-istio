---
title: 基于 iphash 进行负载均衡
type: book
date: "2021-03-02"
---

## 业务场景

根据源 IP 进行负载均衡。

## 解决方案

配置 `DestinationRule`，指定 `useSourceIp` 负载均衡策略:


```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: bookinfo-ratings
spec:
  host: ratings.prod.svc.cluster.local
  trafficPolicy:
    loadBalancer:
      consistentHash:
        useSourceIp: true
```

## 参考资料

* 官方参考文档: [LoadBalancerSettings.ConsistentHashLB](https://istio.io/latest/docs/reference/config/networking/destination-rule/#LoadBalancerSettings-ConsistentHashLB)
