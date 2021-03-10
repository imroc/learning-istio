---
title: 常规检查
type: book
date: "2021-02-03"
weight: 3
draft: true
---

## 检查 port name 是否符合规则

istio 需要根据 svc 的 port name 来检查后端服务用的哪种协议，如果定义不正确，走到了不符合预期的 filter，就会造成一些异常现象。

