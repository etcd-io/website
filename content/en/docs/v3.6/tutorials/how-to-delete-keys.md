---
title: How to delete keys
description: Describes a way to delete etcd keys
weight: 400
---

![04_etcdctl_delete_2016050601](https://storage.googleapis.com/etcd/demo/04_etcdctl_delete_2016050601.gif)

```shell
etcdctl --endpoints=$ENDPOINTS put key myvalue
etcdctl --endpoints=$ENDPOINTS del key

etcdctl --endpoints=$ENDPOINTS put k1 value1
etcdctl --endpoints=$ENDPOINTS put k2 value2
etcdctl --endpoints=$ENDPOINTS del k --prefix
```
