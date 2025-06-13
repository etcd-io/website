---
title: How to conduct leader election in etcd cluster
description: Guide to conducting leader election in an etcd cluster
weight: 900
---

## Prerequisites

- Ensure [`etcd`](https://etcd.io/docs/v3.5/install/) and [`etcdctl`](https://etcd.io/docs/v3.5/install/) is installed.
- Check for active etcd cluster.

`elect` for leader election:

1. The `etcdctl` command is used to conduct leader elections in an etcd cluster. It makes sure that only one client become leader at a time.
2. Ensure the `ENDPOINTS` variable is set with the addresses of each etcd cluster members.
3. Set a unique name for the election for different clients ('*one*' in the given code below).
4. Lastly, set different leaders name for each clients (*p1* and *p2*).


  Command format :
   `etcdctl --endpoints=$ENDPOINTS elect <election-name> <leader-name>`



```shell
etcdctl --endpoints=$ENDPOINTS elect one p1

# another client with the same election name block
etcdctl --endpoints=$ENDPOINTS elect one p2
