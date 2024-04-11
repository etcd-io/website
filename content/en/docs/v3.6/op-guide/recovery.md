---
title: Disaster recovery
weight: 4275
description: etcd v3 snapshot & restore facilities
---

etcd is designed to withstand machine failures. An etcd cluster automatically recovers from temporary failures (e.g., machine reboots) and tolerates up to *(N-1)/2* permanent failures for a cluster of N members. When a member permanently fails, whether due to hardware failure or disk corruption, it loses access to the cluster. If the cluster permanently loses more than *(N-1)/2* members then it disastrously fails, irrevocably losing quorum. Once quorum is lost, the cluster cannot reach consensus and therefore cannot continue accepting updates.

To recover from disastrous failure, etcd v3 provides snapshot and restore facilities to recreate the cluster without v3 key data loss. To recover v2 keys, refer to the [v2 admin guide][v2_recover].

[v2_recover]: /docs/v2.3/admin_guide#disaster-recovery

## Snapshotting the keyspace

Recovering a cluster first needs a snapshot of the keyspace from an etcd member. A snapshot may either be taken from a live member with the `etcdctl snapshot save` command or by copying the `member/snap/db` file from an etcd data directory. For example, the following command snapshots the keyspace served by `$ENDPOINT` to the file `snapshot.db`:

```sh
$ ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db
```

Note that taking the snapshot from the `member/snap/db` file might lose data that has not been written yet, but is included in the wal (write-ahead-log) folder.

## Status of a snapshot

To understand which revision and hash a given snapshot contains, you can use the `etcdutl snapshot status` command:

```sh
$ etcdutl snapshot status snapshot.db -w table
+---------+----------+------------+------------+
|  HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+---------+----------+------------+------------+
| 7ef846e |   485261 |      11642 |      94 MB |
+---------+----------+------------+------------+
```

## Restoring a cluster

### Revision Difference

When you are restoring a cluster, existing clients may perceive the revision going back by many hundreds or thousands. This is due to the fact that a given snapshot only contains the data lineage up until the point of when it was taken, whereas the current state might already be further ahead.

This is particularly a problem when running Kubernetes using etcd, where controllers and operators may use so called `informers` which act as local caches and get notified on updates using watches. Restoring to an older revision may not correctly refresh the caches, causing unpredictable and inconsistent behavior in the controllers.

When restoring from a snapshot in the context of either: known consumers of the watch API, local cached copies of etcd data or when using Kubernetes in general - it is highly recommended to restore using "revision bumps" below. 

### Restoring from snapshot

To restore a cluster, all that is needed is a single snapshot "db" file. A cluster restore with `etcdutl snapshot restore` creates new etcd data directories; all members should restore using the same snapshot. Restoring overwrites some snapshot metadata (specifically, the member ID and cluster ID); the member loses its former identity. This metadata overwrite prevents the new member from inadvertently joining an existing cluster. Therefore in order to start a cluster from a snapshot, the restore must start a new logical cluster.

A simple restore can be excuted like this:

```sh
$ etcdutl snapshot restore snapshot.db --data-dir output-dir
```

### Integrity Checks

Snapshot integrity may be optionally verified at restore time. If the snapshot is taken with `etcdctl snapshot save`, it will have an integrity hash that is checked by `etcdutl snapshot restore`. If the snapshot is copied from the data directory, there is no integrity hash and it will only restore by using `--skip-hash-check`.


### Restoring with revision bump

In order to ensure the revisions are never decreasing after a restore, you can supply the `--bump-revision` option. This option takes a 64 bit integer, which denotes how many revisions to add to the current revision of the snapshot. Since each write to etcd increases the revision by one, you may cover a week old snapshot with bumping by 1'000'000'000 assuming that etcd runs with less than 1500 writes per second. 

In the context of Kubernetes controllers, it is important to also mark all the revisions, including the bump, as compacted using `--mark-compacted`. This ensures that all watches are terminated and etcd does not respond to requests about revisions that happened after taking the snapshot - effectively invalidating its informer caches. 

A full invocation may look like this:

```sh
$ etcdutl snapshot restore snapshot.db --bump-revision 1000000000 --mark-compacted --data-dir output-dir
```

### Restoring with updated membership

The members of an etcd cluster are stored in etcd itself and maintained through the raft consensus algorithm. When quorum is lost entirely, you may want to reconsider where and how the new cluster is formed, for example, on an entirely new set of members.

When restoring from a snapshot, you can directly supply the new membership into the datastore as follows:

```sh
$ etcdutl snapshot restore snapshot.db \
  --name m1 \
  --initial-cluster m1=http://host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host1:2380
```

This ensures that the newly constructed cluster only connects to the other restored members with the given token and not older members that might still be alive and try to connect.

Alternatively, when starting up etcd, you can supply `--force-new-cluster` to overwrite cluster membership while keeping existing application data. Note that this is strongly discouraged because it will panic if other members from previous cluster are still alive. Make sure to save snapshots periodically.


### End-2-End Example

Grab a snapshot from a live cluster using:

```sh
$ etcdctl snapshot save snapshot.db
```

Continuing from the previous example, the following creates new etcd data directories (`m1.etcd`, `m2.etcd`, `m3.etcd`) for a three member cluster:

```sh
$ etcdutl snapshot restore snapshot.db \
  --name m1 \
  --initial-cluster m1=http://host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host1:2380
$ etcdutl snapshot restore snapshot.db \
  --name m2 \
  --initial-cluster m1=http://host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host2:2380
$ etcdutl snapshot restore snapshot.db \
  --name m3 \
  --initial-cluster m1=http://host1:2380,m2=http://host2:2380,m3=http://host3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls http://host3:2380
```

Next, start `etcd` with the new data directories:

```sh
$ etcd \
  --name m1 \
  --listen-client-urls http://host1:2379 \
  --advertise-client-urls http://host1:2379 \
  --listen-peer-urls http://host1:2380 &
$ etcd \
  --name m2 \
  --listen-client-urls http://host2:2379 \
  --advertise-client-urls http://host2:2379 \
  --listen-peer-urls http://host2:2380 &
$ etcd \
  --name m3 \
  --listen-client-urls http://host3:2379 \
  --advertise-client-urls http://host3:2379 \
  --listen-peer-urls http://host3:2380 &
```

Now the restored etcd cluster should be available and serving the keyspace from the snapshot.
