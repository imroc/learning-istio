---
title: 安装 istioctl
type: book
date: "2021-01-26"
weight: 10
---

一键下载:
``` bash
$ curl -sL https://istio.io/downloadIstioctl | sh -
 Downloading istioctl-1.8.2 from https://github.com/istio/istio/releases/download/1.8.2/istioctl-1.8.2-osx.tar.gz ...
istioctl-1.8.2-osx.tar.gz download complete!

Add the istioctl to your path with:
  export PATH=$PATH:$HOME/.istioctl/bin

Begin the Istio pre-installation check by running:
	 istioctl x precheck

Need more information? Visit https://istio.io/docs/reference/commands/istioctl/
```

二进制会被下载到 `~/.istioctl/bin/istioctl`，在我们的 shell 启动脚本里 (`~/.bashrc` 或 `~/.zshrc`) 加入:
``` bash
export PATH=$PATH:$HOME/.istioctl/bin
```

新开终端，检测是否安装成功:
``` bash
$ istioctl version
no running Istio pods in "istio-system"
1.8.2
```