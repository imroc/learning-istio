---
title: Sidecar 停止顺序问题
type: book
date: "2021-04-09"
weight: 2
---

## 背景

Istio 在 1.1 版本之前有个问题: Pod 销毁时，如果进程在退出过程中继续调用其它服务 (比如通知另外的服务进行清理)，会调用失败。

更多详细信息请参考 issue [#7136: Envoy shutting down before the thing it's wrapping can cause failed requests ](https://github.com/istio/istio/issues/7136) 。

## 原因

Kubernetes 在销毁 Pod 的过程中，会同时给所有容器发送 SIGTERM 信号，所以 Envoy 跟业务容器同时开始停止，Envoy 停止过程中不接受新流量，又由于 Istio 会进行流量劫持，所有出向流量都会经过 Envoy 进行转发，如果 Envoy 不接受新流量，就会导致业务调用其它服务失败。

## 社区解决方案

如果 Kubernetes 自身支持容器依赖管理，那这个问题自然就可以解决掉。社区也提出了 [Sidecar Container](https://github.com/kubernetes/enhancements/issues/753) 的特性，只可惜最终还是被废弃了，新的方案还未落地，详细可参考 [这篇笔记](https://imroc.cc/k8s/kep/sidecar-containers.html) 。

后来随着 istio 社区的推进，针对优雅终止场景进行了一些优化:

* 2019-02: Liam White 提交 PR [Envoy Graceful Shutdown](https://github.com/istio/istio/pull/11485) ，让 Pod 在停止过程中 Envoy 能够实现优雅停止 (保持存量连接继续处理，但拒绝所有新连接)，等待 `terminationDrainDuration` 时长后再停掉 envoy 实例。该 PR 最终被合入 istio 1.1。
* 2019-11: Rama Chavali 提交 PR [move to drain listeners admin endpoint](https://github.com/istio/istio/pull/18581) ，将 Envoy 优雅停止的方式从热重启改成调用 Envoy 后来自身提供的 admin 接口 ([/drain_listeners?inboundonly](https://www.envoyproxy.io/docs/envoy/latest/operations/admin#post--drain_listeners?inboundonly)) ，重点在于带上了 `inboundonly` 参数，即仅仅拒绝 inbound 方向的新连接，outbound 的新连接仍然可以正常发起，这也使得 Pod 在停止过程中业务进程继续调用其它服务得以实现。该 PR 最终被合入 istio 1.5。

所以在 istio 1.5 及其以上的版本，在 Pod 停止期间的一小段时间内 (默认 5s)，业务进程仍然可以对其它服务发请求。

## 最佳实践

### 自定义优雅时长

如果你的业务有在停止过程中调用其它服务的需求，使用 istio 1.5 以上版本不做任何额外配置通常也不会有问题，因为会默认给出 5s 的优雅终止时间，这个时长对于绝大部分场景是足够了。如果业务特殊，在停止过程中可能消耗较长时间 (超过 5s)，且需要对其它服务发起调用，这种情况建议使用 istio 1.7 及其以上的版本，支持使用 `proxy.istio.io/config` 这个 [Resource Annotation](https://istio.io/latest/docs/reference/config/annotations/) 来对需要自定义优雅终止时长的服务配置 `terminationDrainDuration`，用法示例:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      annotations:
        proxy.istio.io/config: |
          terminationDrainDuration: 60s # 这里自定义 Envoy 优雅终止时长
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 60 # 若 terminationDrainDuration 超时 30s 则显式指定 terminationGracePeriodSeconds
      containers:
      - name: nginx
        image: "nginx"
```

需要注意的是，如果 `terminationDrainDuration` 大于 30s，需要显式给 Pod 指定 `terminationGracePeriodSeconds`，因为这个值默认为 30s，即 30s 之后容器内进程还未退出就发 SIGKILL 信号将其强制杀死。所以要确保 `terminationGracePeriodSeconds` 大于等于 `terminationDrainDuration` 才好让优雅终止时长完全生效。

### 使用 preStop 来规避

如果业务停止需要的时长不太固定，不好使用固定的优雅时长，也可以给 sidecar 加一个 preStop 脚本，在脚本里通过判断是否还要连接来间接判断应用是否已经退出，等应用退出了之后 envoy 才真正退出。

添加 preStop 可以通过修改 sidecar injector 的全局 configmap 来实现:

```bash
kubectl -n istio-system edit configmap istio-sidecar-injector
```

> 如果使用 TCM，托管网格添加 preStop 需要提工单后台操作，独立网格可以自行修改主集群里的 configmap，但 configmap 名称和这里不一样，会带上版本后缀。

在 values 里面的 `global.proxy` 加入以下 lifecycle 字段:

```json
          "lifecycle": {
            "preStop": {
              "exec": {
                "command": ["/bin/sh", "-c", "while [ $(netstat -plunt | grep tcp | grep -v envoy | wc -l | xargs) -ne 0 ]; do sleep 1; done"]
              },
            },
          },
```