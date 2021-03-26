---
title: Client feature matrix
---

## Features

| Feature                              | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------                              | -------------------- | -------------- |
| Automatic retry                      | Yes                  | .              |
| Retry backoff                        | Yes                  | .              |
| Automatic failover                   | Yes                  | .              |
| Load balancer                        | Round-Robin          | ·              |
| `WithRequireLeader(context.Context)` | Yes                  | .              |
| `TLS`                                | Yes                  | Yes            |
| `SetEndpoints`                       | Yes                  | .              |
| `Sync` endpoints                     | Yes                  | .              |
| `AutoSyncInterval`                   | Yes                  | .              |
| `KeepAlive` ping                     | Yes                  | .              |
| `MaxCallSendMsgSize`                 | Yes                  | .              |
| `MaxCallRecvMsgSize`                 | Yes                  | .              |
| `RejectOldCluster`                   | Yes                  | .              |

## KV

| Feature   | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------   | -------------------- | -------------- |
| `Put`     | Yes                  | .              |
| `Get`     | Yes                  | .              |
| `Delete`  | Yes                  | .              |
| `Compact` | Yes                  | .              |
| `Do(Op)`  | Yes                  | .              |
| `Txn`     | Yes                  | .              |

For details, see the [KV API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#KV).

## Lease

| Feature         | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------         | -------------------- | -------------- |
| `Grant`         | Yes                  | .              |
| `Revoke`        | Yes                  | .              |
| `TimeToLive`    | Yes                  | .              |
| `Leases`        | Yes                  | .              |
| `KeepAlive`     | Yes                  | .              |
| `KeepAliveOnce` | Yes                  | .              |

For details, see the [Lease API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#Lease).

## Watcher

| Feature           | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------           | -------------------- | -------------- |
| `Watch`           | Yes                  | Yes            |
| `RequestProgress` | Yes                  | .              |

For details, see the [Watcher API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#Watcher).

## Cluster

| Feature        | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------        | -------------------- | -------------- |
| `MemberList`   | Yes                  | Yes            |
| `MemberAdd`    | Yes                  | Yes            |
| `MemberRemove` | Yes                  | Yes            |
| `MemberUpdate` | Yes                  | Yes            |

For details, see the [Cluster API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#Cluster).

## Maintenance

| Feature       | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------       | -------------------- | -------------- |
| `AlarmList`   | Yes                  | Yes            |
| `AlarmDisarm` | Yes                  | .              |
| `Defragment`  | Yes                  | .              |
| `Status`      | Yes                  | .              |
| `HashKV`      | Yes                  | .              |
| `Snapshot`    | Yes                  | .              |
| `MoveLeader`  | Yes                  | .              |

For details, see the [Maintenance API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#Maintenance).

## Auth

| Feature                | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------                | -------------------- | -------------- |
| `AuthEnable`           | Yes                  | .              |
| `AuthDisable`          | Yes                  | .              |
| `UserAdd`              | Yes                  | .              |
| `UserDelete`           | Yes                  | .              |
| `UserChangePassword`   | Yes                  | .              |
| `UserGrantRole`        | Yes                  | .              |
| `UserGet`              | Yes                  | .              |
| `UserList`             | Yes                  | .              |
| `UserRevokeRole`       | Yes                  | .              |
| `RoleAdd`              | Yes                  | .              |
| `RoleGrantPermission`  | Yes                  | .              |
| `RoleGet`              | Yes                  | .              |
| `RoleList`             | Yes                  | .              |
| `RoleRevokePermission` | Yes                  | .              |
| `RoleDelete`           | Yes                  | .              |

For details, see the [Auth API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3#Auth).

## clientv3util

| Feature      | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------      | -------------------- | -------------- |
| `KeyExists`  | Yes                  | No             |
| `KeyMissing` | Yes                  | No             |

For details, see the [clientv3util API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/clientv3util).

## Concurrency

| Feature                              | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------                              | -------------------- | -------------- |
| `Session`                            | Yes                  | No             |
| `NewMutex(Session, prefix)`          | Yes                  | No             |
| `NewElection(Session, prefix)`       | Yes                  | No             |
| `NewLocker(Session, prefix)`         | Yes                  | No             |
| `STM Isolation SerializableSnapshot` | Yes                  | No             |
| `STM Isolation Serializable`         | Yes                  | No             |
| `STM Isolation RepeatableReads`      | Yes                  | No             |
| `STM Isolation ReadCommitted`        | Yes                  | No             |
| `STM Get`                            | Yes                  | No             |
| `STM Put`                            | Yes                  | No             |
| `STM Rev`                            | Yes                  | No             |
| `STM Del`                            | Yes                  | No             |

For details, see the [Concurrency API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/concurrency).

## Leasing

| Feature                 | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------                 | -------------------- | -------------- |
| `NewKV(Client, prefix)` | Yes                  | No             |

For details, see the [Leasing API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/leasing).

## Mirror

| Feature       | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------       | -------------------- | -------------- |
| `SyncBase`    | Yes                  | No             |
| `SyncUpdates` | Yes                  | No             |

For details, see the [Mirror API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/mirror).

## Namespace

| Feature   | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------   | -------------------- | -------------- |
| `KV`      | Yes                  | No             |
| `Lease`   | Yes                  | No             |
| `Watcher` | Yes                  | No             |

For details, see the [Namespace API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/namespace).

## Naming

| Feature        | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------        | -------------------- | -------------- |
| `GRPCResolver` | Yes                  | No             |

For details, see the [Naming API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/naming).

## Ordering

| Feature | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| ------- | -------------------- | -------------- |
| `KV`    | Yes                  | No             |

For details, see the [Ordering API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/ordering).

## Snapshot

| Feature   | `clientv3-grpc1.14`  | `jetcd v0.0.2` |
| -------   | -------------------- | -------------- |
| `Save`    | Yes                  | No             |
| `Status`  | Yes                  | No             |
| `Restore` | Yes                  | No             |

For details, see the [Snapshot API reference](https://pkg.go.dev/go.etcd.io/etcd/clientv3/snapshot).

