---
title: How to create locks
description: Guide to creating distributed locks in etcd
weight: 800
---

LOCK acquires a distributed mutex with a given name. Once the lock is acquired, it will be held until etcdctl is terminated.

## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.6/install/)
* A running etcd cluster (see [How to Set Up a Demo etcd Cluster](/docs/v3.6/tasks/operator/how-to-setup-cluster/))

## Creating a lock

Acquire a lock with a specified name:
```shell
etcdctl --endpoints=$ENDPOINTS lock mutex1
```

The lock will be held until the command is terminated with `Ctrl+C`.

### Lock with command execution

You can also execute a command while holding the lock:
```shell
etcdctl --endpoints=$ENDPOINTS lock mutex1 echo "Lock acquired"
```

When using this form, the lock is automatically released after the command completes.

### Visual demonstration

![08_etcdctl_lock_2016050501](https://storage.googleapis.com/etcd/demo/08_etcdctl_lock_2016050501.gif)

## Options

- `--endpoints` - Comma-delimited list of etcd cluster endpoints (default: `http://127.0.0.1:2379`)
- `--ttl` - Time to live in seconds for the lock session (default: 60)

## Releasing a lock

Locks are released in the following ways:

- **Manual release**: Press `Ctrl+C` to terminate the etcdctl lock command
- **Automatic release**: When executing a command with the lock, it is released after the command completes
- **TTL expiration**: The lock automatically expires after the TTL period if not renewed