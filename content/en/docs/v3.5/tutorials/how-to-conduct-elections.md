---
title: How to conduct leader election in etcd cluster
description: Guide to conducting leader election in an etcd cluster
weight: 900
---

## Prerequisites

- Ensure [`etcd`](https://etcd.io/docs/v3.5/install/) and [`etcdctl`](https://etcd.io/docs/v3.5/install/) is installed.
- Check for active etcd cluster.

## Conduct Leader election

The `etcdctl` command is used to conduct leader elections in an etcd cluster. It makes sure that only one client become leader at a time.

 `etcdctl --endpoints=$ENDPOINTS elect <election-name> <leader-name>`

### Example

```shell
etcdctl --endpoints=$ENDPOINTS elect election-name p1

# another client with the same election name block
etcdctl --endpoints=$ENDPOINTS elect election-name p2
```

### Options

- `--endpoints : $ENDPOINTS`

Address of each etcd cluster members.

- `election-name` string

A string identifier for the election. All participants competing for leadership must use the same election name.

- `leader-name` string

Leaders name for each clients `p1` and `p2`.
