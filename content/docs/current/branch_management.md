---
title: 分支管理
weight: 1250
description: etcd 分支管理
---

## 指引

* 在[master branch][master]分支上进行新的开发。
* 主干分支永远保持能正确编译！
* 向后兼容的错误修复程序应以master分支为目标，然后移植到稳定分支。
* 一旦master分支准备好发布，它将被标记并成为新的稳定分支。

etcd团队采用了*滚动发布模型*，并支持两个稳定的etcd版本。





### 主干分支

该`master`分支是我们的开发分支。所有新功能都会优先开发到这里。

要尝试新功能和实验性功能，请拉取`master`并使用它。请注意，`master`由于新功能可能会引入错误，因此可能不稳定。

在发布下一个稳定版本之前，功能PR将被冻结。一个[发布管理](./dev-internal/release.md#release-management)将被分配给主要/次要版本，将引领etcd社区测试，错误修复和释放一到两周的文档。

### 稳定分支

所有带前缀带`release-`均被视为稳定分支。

在每个次要版本发布（`http://semver.org`）之后，我们将为该发行版提供一个新的稳定分支，由[补丁发布管理](./dev-internal/release.md#release-management)进行管理。我们将继续为最新的两个稳定版本修复向后兼容的错误。给定任何补丁程序，每两周一次，将对每一个受支持的发行分支发布一个补丁程序版本，其中包含所有错误修复。



[master]: https://github.com/etcd-io/etcd/tree/master

