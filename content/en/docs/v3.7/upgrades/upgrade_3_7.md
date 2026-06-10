---
title: Upgrade etcd from v3.6 to v3.7
weight: 6700
description: Processes, checklists, and notes on upgrading etcd from v3.6 to v3.7
---

In the general case, upgrading from etcd v3.6 to v3.7 can be a zero-downtime, rolling upgrade:

- one by one, stop the etcd v3.6 processes and replace them with etcd v3.7 processes
- after running all v3.7 processes, new features in v3.7 are available to the cluster

Before [starting an upgrade](#upgrade-procedure), read through the rest of this guide to prepare.

### Upgrade checklists

#### Update 3.6

{{% alert title="Important" color="warning" %}}
Before upgrading to 3.7, make sure that all of your 3.6 members are updated to 3.6.11 or later. Earlier 3.6 patch releases may not be compatible with a rolling upgrade to 3.7.
{{% /alert %}}

#### V2 store

The v2 store has been fully removed in v3.7. The v2 HTTP API (`--enable-v2`), the v2-on-v3 emulation (`--experimental-enable-v2v3`), the v2 discovery service, the `client/v2` package, and the loading of v2 snapshot files are all gone. See the breaking-change references in [CHANGELOG-3.7](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md).

If you are upgrading from a 3.6 cluster these flags are already absent and no action is required. If you are coming from an older release with custom v2 data, follow the [v2 migration guide](../../../v3.4/op-guide/v2-migration/) before upgrading.

#### Go refactoring

v3.7 contains substantial internal refactoring that does not affect normal upgraders, but is worth being aware of when upgrading custom integrations:

- Migration from `gogo/protobuf` to standard `google.golang.org/protobuf` (tracked in [#14533](https://github.com/etcd-io/etcd/issues/14533)).
- Migration of the deprecated `go-grpc-middleware` v1 logging and tags libraries to the v2 interceptors ([#20420](https://github.com/etcd-io/etcd/pull/20420)).
- The OpenTelemetry gRPC interceptors were updated to `otelgrpc` v0.61.0, replacing the deprecated `UnaryServerInterceptor` and `StreamServerInterceptor` with `NewServerHandler` ([#20017](https://github.com/etcd-io/etcd/pull/20017)).

If you embed etcd as a library, build against the `clientv3` API, or depend on internal packages, review the [CHANGELOG](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md) before upgrading.

### Flags removed

All deprecated `--experimental-*` flags have been removed in v3.7 ([#19959](https://github.com/etcd-io/etcd/pull/19959)). In v3.6 each of these was replaced either by a non-experimental flag of the same name or by a `--feature-gates` entry. If you still have any of these set, replace them with the v3.6 equivalent **before** rolling to v3.7, otherwise the v3.7 process will fail to start.

```diff
-etcd --experimental-bootstrap-defrag-threshold-megabytes
-etcd --experimental-compact-hash-check-enabled
-etcd --experimental-compact-hash-check-time
-etcd --experimental-compaction-batch-limit
-etcd --experimental-compaction-sleep-interval
-etcd --experimental-corrupt-check-time
-etcd --experimental-distributed-tracing-address
-etcd --experimental-distributed-tracing-instance-id
-etcd --experimental-distributed-tracing-sampling-rate
-etcd --experimental-distributed-tracing-service-name
-etcd --experimental-downgrade-check-time
-etcd --experimental-enable-distributed-tracing
-etcd --experimental-enable-lease-checkpoint
-etcd --experimental-enable-lease-checkpoint-persist
-etcd --experimental-initial-corrupt-check
-etcd --experimental-memory-mlock
-etcd --experimental-peer-skip-client-san-verification
-etcd --experimental-snapshot-catchup-entries
-etcd --experimental-stop-grpc-service-on-defrag
-etcd --experimental-txn-mode-write-with-shared-buffer
-etcd --experimental-warning-apply-duration
-etcd --experimental-warning-unary-request-duration
-etcd --experimental-watch-progress-notify-interval
```

Refer to the [v3.5 to v3.6 upgrade guide](../upgrade_3_6/) for the mapping from each removed flag to its non-experimental equivalent or `--feature-gates` entry.

### Flags added

None.

### Flags with new defaults

None.

### Server upgrade checklists

#### Upgrade requirements

To upgrade an existing etcd deployment to v3.7, the running cluster must be v3.6.11 or later. If it is on an older minor version, please [upgrade to v3.6](../upgrade_3_6/) first; etcd only supports upgrading one minor version at a time.

Also, to ensure a smooth rolling upgrade, the running cluster must be healthy. Check the health of the cluster by using the `etcdctl endpoint health` command before proceeding.

#### Preparation

Before upgrading etcd, always test the services relying on etcd in a staging environment before deploying the upgrade to the production environment.

Before beginning, [download the snapshot backup](../../op-guide/maintenance/#snapshot-backup). Should something go wrong with the upgrade, it is possible to use this backup to [rollback](#rollback) back to existing etcd version.

#### Mixed versions

While upgrading, an etcd cluster supports mixed versions of etcd members, and operates with the protocol of the lowest common version. The cluster is only considered upgraded once all of its members are upgraded to version v3.7. Internally, etcd members negotiate with each other to determine the overall cluster version, which controls the reported version and the supported features.

#### Rollback

Before upgrading your etcd cluster, please create and [download a snapshot backup](../../op-guide/maintenance/#snapshot-backup) of your etcd cluster. This snapshot can be used to restore the cluster to its pre-upgrade state if needed. If users encounter issues during the upgrade, they should first identify and resolve the root cause. If the cluster is still in a mixed-version state, where at least one member remains on v3.6, they can either replace the binary or image with the old v3.6 version or restore the cluster directly using the snapshot. In this mixed state, the cluster continues to operate as a v3.6 cluster, allowing rollback without following a formal downgrade process.

However, once all members have been upgraded to v3.7, the cluster is considered fully upgraded and rollback using binaries is no longer possible. In that case, the only recovery options are to restore from the snapshot taken before the upgrade or to follow the official [downgrade guide](../../downgrades/downgrading-etcd/) in case your upgrade goes badly.

### Upgrade procedure

This example shows how to upgrade a 3-member v3.6 etcd cluster running on a local machine. The output below is from a real run against etcd v3.6.12 and etcd v3.7.0-rc.0 on a single host with three loopback ports.

#### Step 1: check upgrade requirements

Is the cluster healthy and running v3.6.11 or later?

```bash
etcdctl --endpoints=localhost:2379,localhost:22379,localhost:32379 endpoint health
<<COMMENT
localhost:2379 is healthy: successfully committed proposal: took = 7.681459ms
localhost:22379 is healthy: successfully committed proposal: took = 7.691750ms
localhost:32379 is healthy: successfully committed proposal: took = 7.698000ms
COMMENT

curl http://localhost:2379/version
<<COMMENT
{"etcdserver":"3.6.12","etcdcluster":"3.6.0","storage":"3.6.0"}
COMMENT
```

#### Step 2: download snapshot backup from leader

[Download the snapshot backup](../../op-guide/maintenance/#snapshot-backup) to provide a downgrade path should any problems occur.

etcd leader is guaranteed to have the latest application data, thus fetch snapshot from leader:

```bash
for p in 2379 22379 32379; do
  echo -n "localhost:$p leader="
  curl -sL http://localhost:$p/metrics | grep "^etcd_server_is_leader " | awk '{print $2}'
done
<<COMMENT
localhost:2379 leader=1
localhost:22379 leader=0
localhost:32379 leader=0
COMMENT

etcdctl --endpoints=localhost:2379 snapshot save backup.db
<<COMMENT
{"level":"info","ts":"2026-06-02T07:01:41.863225+0300","caller":"snapshot/v3_snapshot.go:83","msg":"created temporary db file","path":"backup.db.part"}
{"level":"info","ts":"2026-06-02T07:01:41.866451+0300","logger":"client","caller":"v3@v3.6.12/maintenance.go:236","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2026-06-02T07:01:41.874080+0300","caller":"snapshot/v3_snapshot.go:96","msg":"fetching snapshot","endpoint":"localhost:2379"}
{"level":"info","ts":"2026-06-02T07:01:41.877203+0300","caller":"snapshot/v3_snapshot.go:111","msg":"fetched snapshot","endpoint":"localhost:2379","size":"98 kB","took":"13.822583ms","etcd-version":"3.6.0"}
{"level":"info","ts":"2026-06-02T07:01:41.877303+0300","caller":"snapshot/v3_snapshot.go:121","msg":"saved","path":"backup.db"}
Snapshot saved at backup.db
Server version 3.6.0
COMMENT
```

#### Step 3: stop one existing etcd server

When each etcd process is stopped, expected errors will be logged by other cluster members. This is normal since a cluster member connection has been (temporarily) broken. The leader will transfer leadership before exiting:

```bash
{"level":"info","ts":"2026-06-02T07:01:54.949299+0300","caller":"etcdserver/server.go:1274","msg":"leadership transfer finished","local-member-id":"7339c4e5e833c029","old-leader-member-id":"7339c4e5e833c029","new-leader-member-id":"b548c2511513015","took":"101.052625ms"}
{"level":"info","ts":"2026-06-02T07:01:54.949369+0300","caller":"etcdserver/server.go:2349","msg":"server has stopped; stopping cluster version's monitor"}
{"level":"info","ts":"2026-06-02T07:01:55.503219+0300","caller":"embed/etcd.go:626","msg":"stopped serving peer traffic","address":"127.0.0.1:2380"}
```

#### Step 4: restart the etcd server with same configuration

Restart the etcd server with same configuration but with the new etcd binary.

```diff
-etcd-old --name ${name} \
+etcd-new --name ${name} \
  --data-dir /path/to/${name}.etcd \
  --listen-client-urls http://localhost:2379 \
  --advertise-client-urls http://localhost:2379 \
  --listen-peer-urls http://localhost:2380 \
  --initial-advertise-peer-urls http://localhost:2380 \
  --initial-cluster s1=http://localhost:2380,s2=http://localhost:22380,s3=http://localhost:32380 \
  --initial-cluster-token tkn \
  --initial-cluster-state new
```

The new v3.7 etcd will publish its information to the cluster. At this point, the cluster still operates as v3.6 protocol, which is the lowest common version.

> `{"level":"info","ts":"2026-06-02T07:01:58.920780+0300","caller":"membership/cluster.go:296","msg":"set cluster version from store","cluster-version":"3.6"}`
>
> `{"level":"info","ts":"2026-06-02T07:01:58.979186+0300","caller":"etcdserver/server.go:1828","msg":"published local member to cluster through raft","local-member-id":"7339c4e5e833c029","local-member-attributes":"{Name:s1 ClientURLs:[http://localhost:2379]}","cluster-id":"7dee9ba76d59ed53","publish-timeout":"7s"}`

Verify that each member, and then the entire cluster, becomes healthy with the new v3.7 etcd binary:

```bash
etcdctl --endpoints=localhost:2379,localhost:22379,localhost:32379 endpoint status -w table
<<COMMENT
+-----------------+------------------+------------+-----------------+---------+--------+-----------+
|    ENDPOINT     |        ID        |  VERSION   | STORAGE VERSION | DB SIZE | LEADER | RAFT TERM |
+-----------------+------------------+------------+-----------------+---------+--------+-----------+
|  localhost:2379 | 7339c4e5e833c029 | 3.7.0-rc.0 |           3.6.0 |   98 kB |  false |         3 |
| localhost:22379 | 729934363faa4a24 |     3.6.12 |           3.6.0 |   98 kB |  false |         3 |
| localhost:32379 |  b548c2511513015 |     3.6.12 |           3.6.0 |   98 kB |   true |         3 |
+-----------------+------------------+------------+-----------------+---------+--------+-----------+
COMMENT
```

Un-upgraded members and the upgraded member will log messages about the mixed-version state until the entire cluster is upgraded. This is expected and will cease after all etcd cluster members are upgraded to v3.7.

#### Step 5: repeat *step 3* and *step 4* for rest of the members

When all members are upgraded, the cluster will report upgrading to v3.7 successfully:

> `{"level":"info","ts":"2026-06-02T07:02:36.054783+0300","caller":"etcdserver/server.go:2311","msg":"updating cluster version using v3 API","from":"3.6","to":"3.7"}`
>
> `{"level":"info","ts":"2026-06-02T07:02:36.059345+0300","caller":"membership/cluster.go:593","msg":"updated cluster version","cluster-id":"7dee9ba76d59ed53","local-member-id":"7339c4e5e833c029","from":"3.6","to":"3.7"}`
>
> `{"level":"info","ts":"2026-06-02T07:02:36.059409+0300","caller":"etcdserver/server.go:2326","msg":"cluster version is updated","cluster-version":"3.7"}`

```bash
etcdctl --endpoints=localhost:2379,localhost:22379,localhost:32379 endpoint health
<<COMMENT
localhost:2379 is healthy: successfully committed proposal: took = 550.833µs
localhost:32379 is healthy: successfully committed proposal: took = 733.458µs
localhost:22379 is healthy: successfully committed proposal: took = 714.416µs
COMMENT

curl http://localhost:2379/version
<<COMMENT
{"etcdserver":"3.7.0-rc.0","etcdcluster":"3.7.0","storage":"3.7.0"}
COMMENT

curl http://localhost:22379/version
<<COMMENT
{"etcdserver":"3.7.0-rc.0","etcdcluster":"3.7.0","storage":"3.7.0"}
COMMENT

curl http://localhost:32379/version
<<COMMENT
{"etcdserver":"3.7.0-rc.0","etcdcluster":"3.7.0","storage":"3.7.0"}
COMMENT
```
