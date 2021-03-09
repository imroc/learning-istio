---
title: 配置 accesslog
type: book
date: "2021-03-09"
weight: 2
---

## TEXT 格式默认配置

istio 的 json accesslog 配置格式见 [源码](https://github.com/istio/istio/blob/1.8.3/pilot/pkg/networking/core/v1alpha3/accesslog.go#L38) 。转换成字符串为:

```txt
[%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% "%UPSTREAM_TRANSPORT_FAILURE_REASON%" %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%
```

## JSON 格式默认配置

istio 的 json accesslog 配置格式见 [源码](https://github.com/istio/istio/blob/1.8.3/pilot/pkg/networking/core/v1alpha3/accesslog.go#L63) 。转换成字符串为:
```json
{
  "authority": "%REQ(:AUTHORITY)%",
  "bytes_received": "%BYTES_RECEIVED%",
  "bytes_sent": "%BYTES_SENT%",
  "downstream_local_address": "%DOWNSTREAM_LOCAL_ADDRESS%",
  "downstream_remote_address": "%DOWNSTREAM_REMOTE_ADDRESS%",
  "duration": "%DURATION%",
  "istio_policy_status": "%DYNAMIC_METADATA(istio.mixer:status)%",
  "method": "%REQ(:METHOD)%",
  "path": "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%",
  "protocol": "%PROTOCOL%",
  "request_id": "%REQ(X-REQUEST-ID)%",
  "requested_server_name": "%REQUESTED_SERVER_NAME%",
  "response_code": "%RESPONSE_CODE%",
  "response_flags": "%RESPONSE_FLAGS%",
  "route_name": "%ROUTE_NAME%",
  "start_time": "%START_TIME%",
  "upstream_cluster": "%UPSTREAM_CLUSTER%",
  "upstream_host": "%UPSTREAM_HOST%",
  "upstream_local_address": "%UPSTREAM_LOCAL_ADDRESS%",
  "upstream_service_time": "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%",
  "upstream_transport_failure_reason": "%UPSTREAM_TRANSPORT_FAILURE_REASON%",
  "user_agent": "%REQ(USER-AGENT)%",
  "x_forwarded_for": "%REQ(X-FORWARDED-FOR)%"
}
```

## 变量相关参考文档

* istio 官方文档将一些常见的变量给出了示例: https://istio.io/latest/docs/tasks/observability/logs/access-log/#default-access-log-format
* 变量的解释参考 envoy 官方文档: https://www.envoyproxy.io/docs/envoy/latest/configuration/observability/access_log/usage#command-operators