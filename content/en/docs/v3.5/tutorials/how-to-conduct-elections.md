---
title: How to conduct leader election in etcd cluster
description: Guide to conducting leader election in an etcd cluster
weight: 900
---

`elect` for leader election:

![09_etcdctl_elect_2016050501](https://storage.googleapis.com/etcd/demo/09_etcdctl_elect_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS elect one p1

# another client with the same name blocks
etcdctl --endpoints=$ENDPOINTS elect one p2
```
