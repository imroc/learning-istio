---
title: Envoy 将 HTTP Header 转换为小写
type: book
date: "2021-02-24"
---

## 背景
Envoy 在转发 HTTP 请求时，会对 HTTP Header 进行处理，统一转为小写。这个在正常情况下没问题，[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)  规范也说明了处理 HTTP Header 应该是大小写不敏感的。
但在某些特殊场景可能会有问题，比如腾讯云 COS SDK 判断 Context_Lenght header 时使用的时首字母大写的方式，转成小写会导致 COS SDK 不能正确判断返回的 HTTP Response 内容的长度。

## 解决方案
### 方案一: 使用 ServiceEntry 将服务指定为 TCP 类型
可以通过一个类似如下 ServiceEntry 将服务强制指定为 TCP Service，以避免 envoy 对其进行七层的处理。

``` yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: qcloud-cos
spec:
  hosts:
  - "private-1251349835.cos.ap-guangzhou.myqcloud.com"
  location: MESH_INTERNAL
  addresses:
  - 169.254.0.47
  ports:
  - number: 80
    name: tcp
    protocol: TCP
  resolution: DNS
```

### 方案二: 使用 EnvoyFilter 控制 Envoy 处理 Header 的行为
方案一的处理方法把 HTTP 作为 TCP 处理了，会损失一些 HTTP 层面的能力，例如 HTTP 的路由，遥测等。我们还可以通过 EnvoyFilter 设置 http_option 选项，要求 Envoy 采用首字母大写的方式进行处理。
``` yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: http-header-proper-case-words
  namespace: istio-system
spec:
  configPatches:
  - applyTo: NETWORK_FILTER # http connection manager is a filter in Envoy
    match:
      # context omitted so that this applies to both sidecars and gateways
      listener:
        name: 指定 cos使用的listener name，可以从config_dump中查询到
        filterChain:
          filter:
            name: "envoy.http_connection_manager"
    patch:
      operation: MERGE
      value:
        name: "envoy.http_connection_manager"
        typed_config:
          "@type": "type.googleapis.com/envoy.config.filter.network.http_connection_manager.v2.HttpConnectionManager"
          http_protocol_options:
            header_key_format:
              proper_case_words: {}
```
要注意的是 Envoy 只支持两种规则：
1. 全小写
2. 首字母大写

如果应用的 http header 的大小写完全没有规律，就没有办法兼容了。

这两种是可以的：
```
test-upper-case-header: some-value
Test-Upper-Case-Header: some-value
```

类似这种就没有办法兼容了：
```
Test-UPPER-CASE-Header: some-value
```