---
title: 项目结构分析
type: book
date: "2021-01-24"
weight: 2
---

## 核心组件与代码入口

`make build` 会编译出本项目的二进制可执行文件， 从 `Makefile` 中看下 build 会编译哪些对象:
``` makefile
.PHONY: build
build: depend ## Builds all go binaries.
	GOOS=$(GOOS_LOCAL) GOARCH=$(GOARCH_LOCAL) LDFLAGS=$(RELEASE_LDFLAGS) common/scripts/gobuild.sh $(ISTIO_OUT)/ $(STANDARD_BINARIES)
	GOOS=$(GOOS_LOCAL) GOARCH=$(GOARCH_LOCAL) LDFLAGS=$(RELEASE_LDFLAGS) common/scripts/gobuild.sh $(ISTIO_OUT)/ -tags=agent $(AGENT_BINARIES)
```

分成了两批二进制(`STANDARD_BINARIES` 和 `AGENT_BINARIES`)，进一步查找:
``` makefile
AGENT_BINARIES:=./pilot/cmd/pilot-agent
STANDARD_BINARIES:=./istioctl/cmd/istioctl \
  ./pilot/cmd/pilot-discovery \
  ./pkg/test/echo/cmd/client \
  ./pkg/test/echo/cmd/server \
  ./operator/cmd/operator \
  ./cni/cmd/istio-cni \
  ./cni/cmd/istio-cni-repair \
  ./cni/cmd/istio-cni-taint \
  ./cni/cmd/install-cni \
  ./tools/istio-iptables \
  ./tools/bug-report
```

上面列出了本项目所有程序的 main 函数入口目录，比较重要的几个:
* `./pilot/cmd/pilot-discovery`: 这是 istio 最核心的代码入口，也就是我们常说的 istiod，控制面的核心。以前控制面还有 galley, citadel 这些组件，现在全部都合并到 istiod 了。
* `./pilot/cmd/pilot-agent`:  这是数据面生命周期管理组件 pilot-agent，它与 envoy 部署在同一容器中，主要用于管理 envoy 的生命周期 (生成 envoy 初始配置、envoy 健康探测、reload 配置等)。
* `/istioctl/cmd/istioctl`: 管理 istio 的命令行工具。
