---
title: '公网 Ingress 不通'
type: book
date: "2021-03-02"
---

## 问题描述

从公网访问 ingress gateway 不通，但集群内访问对应的 svc 没问题。

## 问题分析

检查 vs 和 gateway 配置的 hosts 为 `*`，且 gateway 上只绑了这一个 vs，按理是可以匹配上路由并转发的。

即便配置有误，那也不应该不通，所以怀疑是防火墙问题。

## 原因

检查节点安全组，没对公网放通 gateway svc 对应的 nodeport。(LB转发方案依赖NodePort)


## 解决方案

安全组对公网放通 gateway svc 的 nodeport，主要是 80 和 443 的 nodeport 放通即可。
