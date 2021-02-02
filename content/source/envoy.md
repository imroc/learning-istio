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
* https://zhuanlan.zhihu.com/p/258777260


## 安装高版本 gcc
envoy 使用 `c++ 17`，需要较高版本 gcc，如果过低会报错，如果不能直接用包管理器安装新版本，可以从[这里](http://mirror.linux-ia64.org/gnu/gcc/releases/) 找新版本 gcc 源码包，下载下来自行编译安装，比如。

下载:
``` bash
wget http://mirror.linux-ia64.org/gnu/gcc/releases/gcc-10.2.0/gcc-10.2.0.tar.gz
```

解压后进入源码目录，下载依赖，编译，安装:

``` bash
./contrib/download_prerequisites
./configure
make -j5
make install
```
## 安装高版本 make
通过源码安装，在[这里](http://ftp.gnu.org/gnu/make/) 下载，如:
``` bash
wget http://ftp.gnu.org/gnu/make/make-4.3.tar.gz
```

解压后编译安装:
``` bash
tar -zxvf make-4.3.tar.gz
cd make-4.3
./configure
make
make install
```

备份旧的 make 命令:
``` bash
mv /usr/bin/make /usr/bin/make-3.82
```

建立软连接:

``` bash
ln -s -f /usr/local/bin/make  /usr/bin/make
```

检查版本:
``` bash
$ make --version
GNU Make 4.3
为 x86_64-pc-linux-gnu 编译
Copyright (C) 1988-2020 Free Software Foundation, Inc.
许可证：GPLv3+：GNU 通用公共许可证第 3 版或更新版本<http://gnu.org/licenses/gpl.html>。
本软件是自由软件：您可以自由修改和重新发布它。
在法律允许的范围内没有其他保证
```

## 安装高版本 glibc
编译 envoy 需要 glibc 版本较高，如果报类似的错误:
``` txt
buildtools/linux64/gn: /lib64/libc.so.6: version `GLIBC_2.18' not found (required by buildtools/linux64/gn)
```

可以从 [这里] 下载高版本 glibc 源码，如:
``` bash
wget http://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.gz
```

解压后进入源码目录，编译安装:
``` bash
mkdir build  # 在glibc-2.32目录下建立build文件夹
cd build  # 进入build目录
../configure --prefix=/opt/glibc-2.32  # 配置glibc并设置当前glibc-2.32安装目录
make && make install  # 编译安装glibc-2.32库
```

查看 so 文件是否安装成功:
``` bash
ls -alh /opt/glibc-2.32/lib/libc-2.32.so
```

建立软链:
``` bash
rm -rf /lib64/libc.so.6 // 先删除先前的libc.so.6软链
ln -s /opt/glibc-2.32/lib/libc-2.32.so /lib64/libc.so.6
```


## 使用 Docker

``` Dockerfile
FROM envoyproxy/envoy-build-ubuntu:c8fa4235714003ba0896287ee2f91cae06e0e407
COPY bazel-cmakelists /bin/bazel-cmakelists
```

## 生成

``` bash
bazel-cmakelists --targets //source/exe:envoy-static --skip_build
```