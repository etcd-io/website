---
title: How to create locks
description: Guide to creating distributed locks in etcd
weight: 800
---

`lock` for distributed lock:

![08_etcdctl_lock_2016050501](https://storage.googleapis.com/etcd/demo/08_etcdctl_lock_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS lock mutex1

# another client with the same name blocks
etcdctl --endpoints=$ENDPOINTS lock mutex1
```
