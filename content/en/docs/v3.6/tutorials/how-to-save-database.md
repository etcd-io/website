---
title: How to save the database
description: Guide to taking a snapshot of the etcd database
weight: 1100
---

## Pre-requisites

* [Install etcdctl, etcdutl](https://etcd.io/docs/v3.6/install/)
* [Setup a local cluster](https://etcd.io/docs/v3.6/dev-guide/local_cluster/)

## Snapshot a database

`snapshot` to save point-in-time snapshot of etcd database:

```bash
etcdctl --endpoints=$ENDPOINT snapshot save DB_NAME
```

### Global Options

#### etcdctl

```bash
--endpoints=[127.0.0.1:2379], gRPC endpoints
```

Snapshot can only be requested from one etcd node, so `--endpoints` flag should contain only one endpoint.

#### etcdutl

```bash
-w, --write-out string   set the output format (fields, json, protobuf, simple, table) (default "simple")
```

### Example

![11_etcdctl_snapshot_2016051001](https://storage.googleapis.com/etcd/demo/11_etcdctl_snapshot_2016051001.gif)

```shell
ENDPOINTS=$HOST_1:2379
etcdctl --endpoints=$ENDPOINTS snapshot save my.db

Snapshot saved at my.db
```

```shell
etcdutl --write-out=table snapshot status my.db

+---------+----------+------------+------------+
|  HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+---------+----------+------------+------------+
| c55e8b8 |        9 |         13 | 25 kB      |
+---------+----------+------------+------------+
```
