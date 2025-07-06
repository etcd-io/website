---
title: How to create locks
description: Guide to creating distributed locks in etcd
weight: 800
---

LOCK acquires a distributed mutex with a given name. Once the lock is acquired, it will be held until etcdctl is terminated.

## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.6/install/)

## Creating a lock

`lock` for distributed lock:

![08_etcdctl_lock_2016050501](https://storage.googleapis.com/etcd/demo/08_etcdctl_lock_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS lock mutex1
```

### Options
- endpoints - defines a comma-delimited list of machine addresses in the cluster.
- ttl - time out in seconds of lock session.
