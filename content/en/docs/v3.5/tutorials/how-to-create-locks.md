---
title: How to create locks
description: 
weight: 800
---


## Overview

A lock is a synchronization mechanism used to control access to a shared resource in distributed system. In the context of etcd, a lock ensures that only one client at a time can perform a specific task or access a critical section of code.

Common use cases include:

- Ensuring only one instance of a scheduled job runs
- Leader election in distributed systems
- Serializing access to shared configuration

etcd's locking mechanism is built on top of leases and key creation, ensuring that locks are automatically realeased if the client crashes or becomes unresponsive.

## Prerequisites

Before you can create and manage locks with etcd, make sure the following requirements are met:

- `etcdctl` installed: You need the `etcdctl` command-line tool installed on your system. You can install it by downloading the binaries from the etcd releases page or using a package manager.

- Running etcd cluster: A healthy, running etcd cluster is required. Ensure the endpoints you plan to use are reachable and the cluster is in a good state.

- Environment Setup:

  - `--endpoints`: The etcd server endpoint, e.g., `--endpoints=127.0.0.1:2379`

  - TLS-related flags (if using secure communication): `--cert`, `--key`, `--cacert`, etc.

## Creating a lock

Simple lock acquisition

```shell
etcdctl --endpoints=127.0.0.1:2379 lock locks/my-lock-name echo "I have the lock"
```

### Flags

- `--endpoints`: The etcd server endpoint, by default: `--endpoints=127.0.0.1:2379`
- `lock`: Acquires a named lock

### What's Happening

1. etcdctl uses the concurrency API to create a lease and attaches it to a lock key ()`locks/my-lock-name/<uuid>`).

2. etcd uses the key's modification revision number to determine which client has acquired the lock (the lowest wins).

3. If the key already exists under that prefix, the client waits until the previous holder releases the lock.

4. Once acquired, the given command is executed (`echo "I have the lock"`).

5. When the command finishes or the process dies, the lease is revoked and the lock is released.

## Releasing a lock

When using the `etcdctl lock` command, the lock is released as soon as the command completes.

```shell
etcdctl lock locks/my-lock-name echo "Task done"
```

When echo completes, `etcdctl` exits, revoking the lease and deleting the lock key.
