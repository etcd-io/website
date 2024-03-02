---
title: How to access etcd
description: Guide to access an etcd cluster
weight: 200
---


![02_etcdctl_access_etcd_2016051001](https://storage.googleapis.com/etcd/demo/02_etcdctl_access_etcd_2016051001.gif)

## Prerequisites

- [etcdctl](/docs/v3.5/dev-guide/interacting_v3/) is required

## Write to an etcd cluster

The `put` command is used to write to etcd in the format `etcdctl --endpoints=<endpoints> put <key> <value> [OPTIONS]`.

```shell
etcdctl --endpoints=$ENDPOINTS put foo "Hello World!"
```
The variables in the above example are:
- $ENDPOINTS = <endpoints>
- foo = <key>
- "Hello World" = <value>

## Read from an etcd cluster

The `get` command is used to read from etcd in the format `etcdctl --endpoints=<endpoints> get <key>`.

```shell
etcdctl --endpoints=$ENDPOINTS get foo
```

The variables in the above example are:
- $ENDPOINTS = <endpoints>
- foo = <key>

All commands can accept an output format by setting `-w` or `--write-out` with an output format: `simple`, `json`, `protobuf`, or `fields`.
The output format is used in the following format `etcdctl --endpoints=<endpoints> --write-out=<format>`.

```shell
etcdctl --endpoints=$ENDPOINTS --write-out="json" get foo
```

The variables in the above example are:
- $ENDPOINTS = <endpoints>
- "json" = <format>
- foo = <value>
