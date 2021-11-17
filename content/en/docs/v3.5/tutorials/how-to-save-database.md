---
title: How to save the database
description: Guide to taking a snapshot of the etcd database
weight: 1100
---


`snapshot` to save point-in-time snapshot of etcd database:

![11_etcdctl_snapshot_2016051001](https://storage.googleapis.com/etcd/demo/11_etcdctl_snapshot_2016051001.gif)

Snapshot can only be requested from one etcd node, so `--endpoints` flag should contain only one endpoint.

```shell
ENDPOINTS=$HOST_1:2379
etcdctl --endpoints=$ENDPOINTS snapshot save my.db

Snapshot saved at my.db
```

```shell
etcdctl --write-out=table --endpoints=$ENDPOINTS snapshot status my.db

+---------+----------+------------+------------+
|  HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+---------+----------+------------+------------+
| c55e8b8 |        9 |         13 | 25 kB      |
+---------+----------+------------+------------+
```
