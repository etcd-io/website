---
title: Maintenance
weight: 4450
description: Periodic etcd cluster maintenance guide
---

## Overview

An etcd cluster needs periodic maintenance to remain reliable. Depending on an etcd application's needs, this maintenance can usually be automated and performed without downtime or significantly degraded performance.

All etcd maintenance manages storage resources consumed by the etcd keyspace. Failure to adequately control the keyspace size is guarded by storage space quotas; if an etcd member runs low on space, a quota will trigger cluster-wide alarms which will put the system into a limited-operation maintenance mode. To avoid running out of space for writes to the keyspace, the etcd keyspace history must be compacted. Storage space itself may be reclaimed by defragmenting etcd members. Finally, periodic snapshot backups of etcd member state makes it possible to recover any unintended logical data loss or corruption caused by operational error.

## Raft log retention

`etcd --snapshot-count` configures the number of applied Raft entries to hold in-memory before compaction. When `--snapshot-count` reaches, server first persists snapshot data onto disk, and then truncates old entries. When a slow follower requests logs before a compacted index, leader sends the snapshot forcing the follower to overwrite its state.

Higher `--snapshot-count` holds more Raft entries in memory until snapshot, thus causing [recurrent higher memory usage](https://github.com/kubernetes/kubernetes/issues/60589#issuecomment-371977156). Since leader retains latest Raft entries for longer, a slow follower has more time to catch up before leader snapshot. `--snapshot-count` is a tradeoff between higher memory usage and better availabilities of slow followers.

Since v3.2, the default value of `--snapshot-count` has [changed from from 10,000 to 100,000](https://github.com/etcd-io/etcd/pull/7160).

In performance-wise, `--snapshot-count` greater than 100,000 may impact the write throughput. Higher number of in-memory objects can slow down [Go GC mark phase `runtime.scanobject`](https://golang.org/src/runtime/mgc.go), and infrequent memory reclamation makes allocation slow. Performance varies depending on the workloads and system environments. However, in general, too frequent compaction affects cluster availabilities and write throughputs. Too infrequent compaction is also harmful placing too much pressure on Go garbage collector. See [Understanding Performance Aspects of etcd and Raft](https://www.slideshare.net/mitakeh/understanding-performance-aspects-of-etcd-and-raft) for more research results.

## History compaction: v3 API Key-Value Database

Since etcd keeps an exact history of its keyspace, this history should be periodically compacted to avoid performance degradation and eventual storage space exhaustion. Compacting the keyspace history drops all information about keys superseded prior to a given keyspace revision. The space used by these keys then becomes available for additional writes to the keyspace.

The keyspace can be compacted automatically with `etcd`'s time windowed history retention policy, or manually with `etcdctl`. The `etcdctl` method provides fine-grained control over the compacting process whereas automatic compacting fits applications that only need key history for some length of time.

An `etcdctl` initiated compaction works as follows:

```sh
# compact up to revision 3
$ etcdctl compact 3
```

Revisions prior to the compaction revision become inaccessible:

```sh
$ etcdctl get --rev=2 somekey
Error:  rpc error: code = 11 desc = etcdserver: mvcc: required revision has been compacted
```

### Auto Compaction

`etcd` can be set to automatically compact the keyspace with the `--auto-compaction-mode` and `--auto-compaction-retention` options. There are two compaction modes: `periodic` (default) and `revision`.

#### Periodic compaction

Periodic compaction retains a time-based window of keyspace history:

```sh
# keep one hour of history
$ etcd --auto-compaction-retention=1h
```

The retention value specifies how much history to keep. A record will not be compacted until approximately that duration after it was created. This ensures that slow watchers can still catch up within the retention window.

When the retention period is greater than 1 hour, etcd compacts every hour while maintaining the full retention window. When the retention period is 1 hour or less, etcd compacts at the retention period interval.

For example, with `--auto-compaction-retention=10h`, etcd waits 10 hours for the first compaction, then compacts every hour afterwards:

```text
0hr  (rev = 1)
1hr  (rev = 10)
...
8hr  (rev = 80)
9hr  (rev = 90)
10hr (rev = 100, Compact(1))
11hr (rev = 110, Compact(10))
...
```

Recommended values depend on the use case:

- Frequent updates to the same keys: a short period such as `1h` or `30m`
- Infrequent updates: a longer period such as `24h`, `48h`, or `72h`
- General-purpose default: `10h`

#### Revision compaction

Revision compaction retains a fixed number of revisions:

```sh
# keep 1000 revisions
$ etcd --auto-compaction-mode=revision --auto-compaction-retention=1000
```

etcd checks every 5 minutes and compacts on `"latest revision" - 1000`. For example, when the latest revision is 30000, it compacts on revision 29000.

## Defragmentation

After compacting the keyspace, the backend database may exhibit internal fragmentation. Any internal fragmentation is space that is free to use by the backend but still consumes storage space. Compacting old revisions internally fragments `etcd` by leaving gaps in backend database. Fragmented space is available for use by `etcd` but unavailable to the host filesystem. In other words, deleting application data does not reclaim the space on disk.

The process of defragmentation releases this storage space back to the file system. Defragmentation is issued on a per-member basis so that cluster-wide latency spikes may be avoided.

To defragment an etcd member, use the `etcdctl defrag` command:

```sh
$ etcdctl defrag
Finished defragmenting etcd member[127.0.0.1:2379]
```

**Note that defragmentation to a live member blocks the system from reading and writing data while rebuilding its states**.

**Note that defragmentation request does not get replicated over cluster. That is, the request is only applied to the local node. Specify all members in `--endpoints` flag or `--cluster` flag to automatically find all cluster members.**

Run defragment operations for all endpoints in the cluster associated with the default endpoint:

```bash
$ etcdctl defrag --cluster
Finished defragmenting etcd member[http://127.0.0.1:2379]
Finished defragmenting etcd member[http://127.0.0.1:22379]
Finished defragmenting etcd member[http://127.0.0.1:32379]
```

To defragment an etcd data directory directly, while etcd is not running, use the command:

```sh
etcdutl defrag --data-dir <path-to-etcd-data-dir>
```

## Space quota

The space quota in `etcd` ensures the cluster operates in a reliable fashion. Without a space quota, `etcd` may suffer from poor performance if the keyspace grows excessively large, or it may simply run out of storage space, leading to unpredictable cluster behavior. If the keyspace's backend database for any member exceeds the space quota, `etcd` raises a cluster-wide alarm that puts the cluster into a maintenance mode which only accepts key reads and deletes. Only after freeing enough space in the keyspace and defragmenting the backend database, along with clearing the space quota alarm can the cluster resume normal operation.

By default, `etcd` sets a conservative space quota suitable for most applications, but it may be configured on the command line, in bytes:

```sh
# set a very small 16 MiB quota
$ etcd --quota-backend-bytes=$((16*1024*1024))
```

The space quota can be triggered with a loop:

```sh
# fill keyspace
$ while [ 1 ]; do dd if=/dev/urandom bs=1024 count=1024  | ETCDCTL_API=3 etcdctl put key  || break; done
...
Error:  rpc error: code = 8 desc = etcdserver: mvcc: database space exceeded
# confirm quota space is exceeded
$ ETCDCTL_API=3 etcdctl --write-out=table endpoint status
+----------------+------------------+-----------+---------+-----------+-----------+------------+
|    ENDPOINT    |        ID        |  VERSION  | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+----------------+------------------+-----------+---------+-----------+-----------+------------+
| 127.0.0.1:2379 | bf9071f4639c75cc | 2.3.0+git | 18 MB   | true      |         2 |       3332 |
+----------------+------------------+-----------+---------+-----------+-----------+------------+
# confirm alarm is raised
$ ETCDCTL_API=3 etcdctl alarm list
memberID:13803658152347727308 alarm:NOSPACE
```

Removing excessive keyspace data and defragmenting the backend database will put the cluster back within the quota limits:

```sh
# get current revision
$ rev=$(ETCDCTL_API=3 etcdctl --endpoints=:2379 endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')
# compact away all old revisions
$ ETCDCTL_API=3 etcdctl compact $rev
compacted revision 1516
# defragment away excessive space
$ ETCDCTL_API=3 etcdctl defrag
Finished defragmenting etcd member[127.0.0.1:2379]
# disarm alarm
$ ETCDCTL_API=3 etcdctl alarm disarm
memberID:13803658152347727308 alarm:NOSPACE
# test puts are allowed again
$ ETCDCTL_API=3 etcdctl put newkey 123
OK
```

The metric `etcd_mvcc_db_total_size_in_use_in_bytes` indicates the actual database usage after a history compaction, while `etcd_debugging_mvcc_db_total_size_in_bytes` shows the database size including free space waiting for defragmentation. The latter increases only when the former is close to it, meaning when both of these metrics are close to the quota, a history compaction is required to avoid triggering the space quota.

`etcd_debugging_mvcc_db_total_size_in_bytes` is renamed to `etcd_mvcc_db_total_size_in_bytes` from v3.4.

**NOTE:** it is possible to get an `ErrGRPCNoSpace` error for a Put/Txn/LeaseGrant request, and still have the write request succeed in the backend, because etcd checks space quota at the API layer and the internal Apply layer, and the Apply layer will only raise the `NOSPACE` alarm without blocking the transaction from proceeding.

## Snapshot backup

Snapshotting the `etcd` cluster on a regular basis serves as a durable backup for an etcd keyspace. By taking periodic snapshots of an etcd member's backend database, an `etcd` cluster can be recovered to a point in time with a known good state.

A snapshot is taken with `etcdctl`:

```sh
$ etcdctl snapshot save backup.db
$ etcdutl --write-out=table snapshot status backup.db
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| fe01cf57 |       10 |          7 | 2.1 MB     |
+----------+----------+------------+------------+
```
