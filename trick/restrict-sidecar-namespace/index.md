---
title: "限制 namespace 以减少 sidecar 资源占用"
type: book
date: "2021-05-11"
---

## 背景

istio 默认会下发 mesh 内集群服务所有可能需要的信息，以便让 sidecar 能够与任意 workload 通信。当集群规模较大，服务数量多，namespace 多，可能就会导致 sidecar 占用资源很高 (比如十倍于业务容器)。

如果只有部分 namespace 使用了 istio (sidecar 自动注入)，而网格中的服务与其它没有注入 sidecar 的 namespace 的服务没有多大关系，可以配置下 istio 的 `Sidecar` 资源，限制一下 namespace，避免 sidecar 加载大量无用 outbound 的规则。

## 配置方法

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Sidecar
metadata:
  name: default
  namespace: istio-system
spec:
  egress:
  - hosts:
    - "prod/*"
    - "test/*"
```

* 定义在 istio-system 命名空间下表示 Sidecar 配置针对所有 namespace 生效。
* 在 egress 的 hosts 配置中加入开启了 sidecar 自动注入的 namespace，表示只下发这些跟这些 namespace 相关的 outbound 规则。

## 参考资料

* [Istio Sidecar 资源官方参考文档](https://istio.io/latest/docs/reference/config/networking/sidecar/)