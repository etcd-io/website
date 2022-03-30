---
title: How to access etcd
description: Guide to access an etcd cluster
weight: 200
---


![02_etcdctl_access_etcd_2016051001](https://storage.googleapis.com/etcd/demo/02_etcdctl_access_etcd_2016051001.gif)

`put` command to write:

```shell
etcdctl --endpoints=$ENDPOINTS put foo "Hello World!"
```

`get` to read from etcd:

```shell
etcdctl --endpoints=$ENDPOINTS get foo
etcdctl --endpoints=$ENDPOINTS --write-out="json" get foo
```
