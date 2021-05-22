---
title: 集群权限问题
type: book
date: "2021-04-09"
weight: 20
---

## 背景

使用子账号身份登录登录腾讯云控制台操作服务网格，有时可能会遇到权限问题，比如关联集群失败，提示权限问题:

![](1.png)

或者查看服务时提示权限不足:

![](2.png)

## 原因

核心点在于当前登录的子账号需要有操作网格所关联集群的权限，如果没有或者部分集群没有，就需要给子账号授权一下 (每个集群都需要)，下面是授权方法。

## 集群授权方法

首先登录集群创建者的腾讯云账号 (用该账号为子账号授权)，然后进入 [TKE 控制台](https://console.cloud.tencent.com/tke2/cluster) ，再进入 【授权管理】-【RBAC策略生成器】:

![](3.png)

勾选要授权的子账号:

![](4.png)

最后授权一下管理员权限即可:

![](5.png)