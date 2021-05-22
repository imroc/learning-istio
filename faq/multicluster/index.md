---
title: "多集群相关问题"
type: book
date: "2021-05-20"
weight: 130
draft: true
---

## 概述

本文介绍 istio 多集群下需要注意的问题。

## 跨集群访问 service

同一网格的多个集群之间通过 service 调用，可能调用失败，报错 dns 解析失败。原因是