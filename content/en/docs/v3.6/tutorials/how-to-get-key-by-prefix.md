---
title: How to get keys by prefix
description: Guide to extracting etcd keys by their prefix
weight: 300
---

![03_etcdctl_get_by_prefix_2016050501](https://storage.googleapis.com/etcd/demo/03_etcdctl_get_by_prefix_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS put web1 value1
etcdctl --endpoints=$ENDPOINTS put web2 value2
etcdctl --endpoints=$ENDPOINTS put web3 value3

etcdctl --endpoints=$ENDPOINTS get web --prefix
```