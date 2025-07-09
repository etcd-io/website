---
title: How to watch keys
description: Guide to watching etcd keys
weight: 600
---

## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.6/install/)

## Watching keys
`watch` to get notified of future changes:

```bash
etcdctl watch $KEY [$END_KEY]
```

### Options

```bash
-i, --interactive[=false]: interactive mode
--prefix[=false]: watch on a prefix if prefix is set
--rev=0: Revision to start watching
--prev-kv[=false]: get the previous key-value pair before the event happens
--progress-notify[=false]: get periodic watch progress notification from server
```

### Options inherited from parent commands

```bash
--endpoints="127.0.0.1:2379": gRPC endpoints
```

### Examples
![06_etcdctl_watch_2016050501](https://storage.googleapis.com/etcd/demo/06_etcdctl_watch_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS watch stock1
etcdctl --endpoints=$ENDPOINTS put stock1 1000

etcdctl --endpoints=$ENDPOINTS watch stock --prefix
etcdctl --endpoints=$ENDPOINTS put stock1 10
etcdctl --endpoints=$ENDPOINTS put stock2 20
```

