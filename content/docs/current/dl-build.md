---
title: 下载并构建
weight: 1150
description: 下载和构建etcd不同版本的说明
---

## 系统要求

etcd性能基准测试在8个vCPU，16GB RAM，50GB SSD GCE实例上运行etcd，但是对于大多数用例而言，任何具有低延迟存储和几GB内存的相对较新的计算机都足够。具有大型v2数据存储的应用程序将比大型v3数据存储需要更多的内存，因为数据保留在匿名内存中，而不是从文件映射的内存中。要在云提供程序上运行etcd，请参阅 [硬件示例配置][example-hardware-configurations]文档。

## 下载预构建的二进制文件

获得etcd的最简单方法是使用可用于OSX，Linux，Windows，appc和Docker的预构建发行版二进制文件之一。有关使用这些二进制文件的说明，请参见 [GitHub发布页面][github-release]。

## 构建最新版本

对于那些想尝试最新版本的人，请从master分支构建etcd。 需要Go版本1.13+来构建最新版本的etcd。为了确保etcd是根据经过良好测试的库构建的，etcd提供其对正式发行二进制文件的依赖关系。但是，etcd的供应商也是可选的，以避免在嵌入etcd服务器或使用etcd客户端时潜在的导入冲突。

在没有`GOPATH`的情况下，使用官方的`build`脚本从`master`分支构建`etcd`：

```sh
$ git clone https://github.com/etcd-io/etcd.git
$ cd etcd
$ ./build
```

通过以下方式`go get`,从`master`分支来构建一个模块化的`etcd`：

```sh
# GOPATH should be set
$ echo $GOPATH
/Users/example/go
$ go get -v go.etcd.io/etcd/v3
$ go get -v go.etcd.io/etcd/v3/etcdctl
```

## 测试安装

通过启动etcd并设置密钥来检查etcd二进制文件是否正确构建。

### 启动etcd

如果etcd是没有使用`go get`构建的，请运行以下命令：

```sh
$ ./bin/etcd
```

如果etcd是使用`go get`构建的，请运行以下命令：

```sh
$ $GOPATH/bin/etcd
```

### 设置key值

使用如下命令：

```sh
$ ./bin/etcdctl put foo bar
OK
```

（或`$GOPATH/bin/etcdctl put foo bar`如果etcdctl是使用`go get`安装的）

如果打印出OK，则etcd正常工作！

[github-release]: https://github.com/etcd-io/etcd/releases/
[go]: https://golang.org/doc/install
[example-hardware-configurations]: op-guide/hardware.md#example-hardware-configurations
