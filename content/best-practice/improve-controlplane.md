---
title: 控制面性能优化
type: book
date: "2021-01-27"
weight: 3
---

## istiod 负载均衡
envoy 定时重连

## istiod HPA
istiod 无状态，可水平扩展

## xDS 按需下发

* lazy loading

## batch 推送间隔优化
istiod推送流控规则有合并推送策略，目前这个时间间隔默认值为100ms。可配，一般很少用户会关心这个，在 mesh 全局配置中可以改: PILOT_DEBOUNCE_AFTER 和 PILOT_DEBOUNCE_MAX。  主要取决于：用户期望流控规则更新的实时性，以及 istiod 稳定性的权衡，如果期望实时性高，则把防抖动时间设置短些，如果mesh规模大，希望istiod提高稳定性，则把防抖动时间设置长些。
