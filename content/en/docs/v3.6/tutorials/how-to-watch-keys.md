---
title: How to watch keys
description: Guide to watching etcd keys
weight: 600
---


`watch` to get notified of future changes:

![06_etcdctl_watch_2016050501](https://storage.googleapis.com/etcd/demo/06_etcdctl_watch_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS watch stock1
etcdctl --endpoints=$ENDPOINTS put stock1 1000

etcdctl --endpoints=$ENDPOINTS watch stock --prefix
etcdctl --endpoints=$ENDPOINTS put stock1 10
etcdctl --endpoints=$ENDPOINTS put stock2 20
```

