---
title: How to get keys by prefix
description: Guide to extracting etcd keys by their prefix
weight: 300
---

## Pre-requisites

* [Install etcdctl](https://etcd.io/docs/v3.5/install/)
* [Setup a local cluster](https://etcd.io/docs/v3.5/dev-guide/local_cluster/)

## Get keys by prefix

```bash
$ etcdctl --endpoints=$ENDPOINTS get PREFIX --prefix
```

### Global Options

```bash
--endpoints=[127.0.0.1:2379], gRPC endpoints
```

### Options

```bash
--prefix, get a range of keys with matching prefix
```

### Example

![03_etcdctl_get_by_prefix_2016050501](https://storage.googleapis.com/etcd/demo/03_etcdctl_get_by_prefix_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS put web1 value1
etcdctl --endpoints=$ENDPOINTS put web2 value2
etcdctl --endpoints=$ENDPOINTS put web3 value3

etcdctl --endpoints=$ENDPOINTS get web --prefix
```
