---
title: How to conduct leader election in etcd cluster
description: Steps for conducting a leader election through the etcdctl client
weight: 900
---

## Prerequisites

- Ensure [`etcd`](https://etcd.io/docs/v3.5/install/) and [`etcdctl`](https://etcd.io/docs/v3.5/install/) is installed.
- Check for active etcd cluster.

## Conduct Leader election

The `etcdctl` command is used to conduct leader elections in an etcd cluster. It makes sure that only one client can become leader at a time.

`etcdctl --endpoints=$ENDPOINTS elect <election-name> [proposal]`

```shell
etcdctl --endpoints=$ENDPOINTS elect election-name p1
```

### Options

- `--endpoints : $ENDPOINTS`

Address of each etcd cluster members.

- `election-name` string

A string identifier for the election. All participants competing for leadership must use the same election name.

- `leader-name` string

Proposal value of the new leader.

### Example

```shell
./etcdctl elect my-election proposal1
my-election/694d99fafea88404
proposal1

another election:
./etcdctl elect new-election proposal1
new-election/694d99fafea8840f
proposal1
```
