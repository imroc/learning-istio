---
title: 无法访问不带 sidecar 的Pod
type: book
date: "2021-02-24"
---

## 问题现象
不能从一个带sidecar proxy的pod访问到Redis服务

## 问题分析
Redis是一个Headless服务，而Istio 1.7 之前的版本对Headless服务的处理有问题，会缺省启用mTLS。

## 解决方案

在 1.7 之前可以采用DR规则禁用该服务的mTLS 来规避:
``` yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
name: mysql-service
namespace: test
spec:
  exportTo:
  - '*'
  host: redis-service
  subsets: []
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    tls:
      mode: DISABLE

```
该问题在Isitio 1.7中已经修复: https://github.com/istio/istio/pull/24319
