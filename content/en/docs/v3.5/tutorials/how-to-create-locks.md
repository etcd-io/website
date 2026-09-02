---
title: Creating and releasing locks
description: Guide to creating distributed locks in etcd
weight: 800
---

## Prerequisites

* [etcdctl](../install.md) installed and available on your `PATH`
* A running etcd cluster (local single-node is fine for learning)
* Two terminals if you want to actually see the lock work: one session
  holds `mutex1`, the other waits on the same name

## Flags and terms used in the examples

* `--endpoints` — etcd client URLs (for example `http://127.0.0.1:2379`)
* `lock` — etcdctl subcommand that acquires a named distributed lock
* lock name (for example `mutex1`) — the string that identifies the lock; only one client can hold a given name at a time

Clients use locks when only one process should run a critical section at a time (leader-side work, exclusive maintenance, etc.). Holding a lock is tied to the client's session; if the client disconnects, etcd eventually releases the lock so others can proceed.

## Create (acquire) a lock

`etcdctl lock` blocks until the named lock is free, then holds it and runs a command (default: print the lock key and wait until interrupted).

![08_etcdctl_lock_2016050501](https://storage.googleapis.com/etcd/demo/08_etcdctl_lock_2016050501.gif)

```shell
export ENDPOINTS=http://127.0.0.1:2379

etcdctl --endpoints=$ENDPOINTS lock mutex1
```

A second client using the **same** lock name blocks until the first releases:

```shell
# another terminal
etcdctl --endpoints=$ENDPOINTS lock mutex1
```

## Release a lock

There is no separate `unlock` subcommand. Release the lock by **ending the etcdctl process** that holds it (Ctrl-C if it is waiting in the foreground, or terminate the command you passed to `lock`).

When the holder exits cleanly, the lock becomes available to the next waiter. If the holder crashes, the lock is released when the underlying lease expires.

To run work under the lock and release automatically when the work finishes:

```shell
etcdctl --endpoints=$ENDPOINTS lock mutex1 -- etcdctl --endpoints=$ENDPOINTS put /critical done
```

The lock is held only for the lifetime of the command after `--`.
