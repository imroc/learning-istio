---
title: 使用 istio-operator 安装 istio
type: book
date: "2021-01-26"
weight: 3
---

## 安装 istioctl

需要先安装 istioctl，参考 [安装 istioctl](../install-istioctl/)


## 使用 istioctl 安装 istio-operator

一键安装:
``` bash
$ istioctl operator init
Installing operator controller in namespace: istio-operator using image: docker.io/istio/operator:1.8.2
Operator controller will watch namespaces: istio-system
✔ Istio operator installed
✔ Installation complete
```

检查 operator 是否 running:
``` bash
$ kubectl -n istio-operator get pods
NAME                              READY   STATUS    RESTARTS   AGE
istio-operator-675b8ff647-n4bvc   1/1     Running   0          75s
```

## 安装 istio

准备 `istio.yaml`:
``` yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: demo
```

安装:
``` bash
kubectl apply -f istio.yaml
```

查看是否安装成功:
``` bash
$ kubectl -n istio-system get pods
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-69d75b5f96-jrsd9    1/1     Running   0          3m9s
istio-ingressgateway-674d7d9bb5-cthhs   1/1     Running   0          3m9s
istiod-57799dfcf9-wftrt                 1/1     Running   0          3m35s
```

查看 ingressgateway 的 LB 是否正常创建:

``` bash
$ kubectl -n istio-system get svc
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      172.21.254.245   <none>           80/TCP,443/TCP,15443/TCP                                                     5m41s
istio-ingressgateway   LoadBalancer   172.21.255.248   120.53.204.198   15021:31590/TCP,80:30547/TCP,443:30701/TCP,31400:30329/TCP,15443:31790/TCP   5m41s
istiod                 ClusterIP      172.21.254.57    <none>           15010/TCP,15012/TCP,443/TCP,15014/TCP                                        6m8s
```

拿到流量入口(LB) 的 IP 地址 `120.53.204.198`，若要通过域名访问，配置域名解析到该 IP 地址 (如果使用 80/443 访问，国内部署需要备案)。