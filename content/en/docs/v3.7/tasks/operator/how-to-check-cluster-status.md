---
title: How to check Cluster status
description: Guide to checking etcd cluster status
weight: 1000
---

## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.6/install/)

## Check Overall Status

`endpoint status` to check the overall status of each endpoint specified in `--endpoints` flag:

```bash
etcdctl endpoint status (--endpoints=$ENDPOINTS|--cluster)
```

### Options

```bash
--cluster[=false]: use all endpoints from the cluster member list
```

## Check Health

`endpoint health` to check the healthiness of each endpoint specified in `--endpoints` flag:

```bash
etcdctl endpoint health (--endpoints=$ENDPOINTS|--cluster)
```

### Options

```bash
--cluster[=false]: use all endpoints from the cluster member list
```

## Check KV Hash

`endpoint hashkv` to check the KV history hash of each endpoint specified in `--endpoints` flag:

```bash
etcdctl endpoint hashkv (--endpoints=$ENDPOINTS|--cluster) [rev=$REV]
```

### Options

```bash
--cluster[=false]: use all endpoints from the cluster member list
--rev=0: maximum revision to hash (default: latest revision)
```

## Options inherited from parent commands

```bash
--endpoints="127.0.0.1:2379": gRPC endpoints
-w, --write-out="simple": set the output format (fields, json, protobuf, simple, table)
```

### Examples

```shell
etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status

+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|    ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 10.240.0.17:2379 | 4917a7ab173fabe7 |  3.5.0  |   45 kB |      true |      false |         4 |      16726 |              16726 |        |
| 10.240.0.18:2379 | 59796ba9cd1bcd72 |  3.5.0  |   45 kB |     false |      false |         4 |      16726 |              16726 |        |
| 10.240.0.19:2379 | 94df724b66343e6c |  3.5.0  |   45 kB |     false |      false |         4 |      16726 |              16726 |        |
+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------|
```

```shell
etcdctl --endpoints=$ENDPOINTS endpoint health

10.240.0.17:2379 is healthy: successfully committed proposal: took = 3.345431ms
10.240.0.19:2379 is healthy: successfully committed proposal: took = 3.767967ms
10.240.0.18:2379 is healthy: successfully committed proposal: took = 4.025451ms
```

```shell
etcdctl --cluster endpoint hashkv  --write-out=table

+------------------+------------+---------------+
|     ENDPOINT     |    HASH    | HASH REVISION |
+------------------+------------+---------------+
| 10.240.0.17:2379 | 3892279174 |             3 |
| 10.240.0.18:2379 | 3892279174 |             3 |
| 10.240.0.19:2379 | 3892279174 |             3 |
+------------------+------------+---------------+
```
