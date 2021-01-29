---
title: 使用 Clion 阅读 Envoy 源码
type: book
date: "2021-01-29"
weight: 3
---

## 生成 CMakeLists.txt

参考:
* https://atbug.com/read-envoy-source-code-in-clion/
* https://istio.cn/t/topic/112


## 安装高版本 gcc
从[这里](http://mirror.linux-ia64.org/gnu/gcc/releases/) 找新版本 gcc 源码包，下载下来，比如:

``` bash
wget http://mirror.linux-ia64.org/gnu/gcc/releases/gcc-10.2.0/gcc-10.2.0.tar.gz
```

加压后进入源码目录，下载依赖，编译，安装:

``` bash
./contrib/download_prerequisites
./configure
make -j5
make install
```