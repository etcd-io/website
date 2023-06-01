---
title: Data Corruption
weight: 5000
description: etcd data corruption and recovery
---

etcd has built in automated data corruption detection to prevent member state from diverging.

## Enabling data corruption detection

Data corruption detection can be done in two ways:
* Initial check, enabled with `--experimental-initial-corrupt-check` flag.
* Periodic check, enabled with `--experimental-corrupt-check-time` flag.

Initial check will be executed during bootstrap of etcd member.
Member will compare its persistent state vs other members and exit if there is a mismatch.

Periodic check will be executed by the cluster leader in a cluster that is already running.
Leader will compare its persistent state vs other members and raise a CORRUPT ALARM if there is a mismatch.
Period of checks is configured using format: `1m` - every minute, `1h` - evey hour.
Recommended period is a couple of hours as there is a high performance cost.
Running a check requires computing a checksum by scanning entire etcd content at given revision.

## Restoring a corrupted member

There are three ways to restore a corrupted member:
* Purge member persistent state
* Replace member
* Restore whole cluster

After the corrupted member is restored, CORRUPT ALARM can be removed.

### Purge member persistent state

Members state can be purged by:
1. Stopping the etcd instance.
2. Backing up etcd data directory.
3. Moving out the `snap` subdirectory from the etcd data directory.
6. Starting `etcd` with `--initial-cluster-state=existing` and cluster members listed in `--initial-cluster`.

Etcd member is expected to download up-to-date snapshot from the leader.

### Replace member

Member can be replaced by:
1. Stopping the etcd instance.
2. Backing up the etcd data directory.
3. Removing the data directory.
4. Removing the member from cluster by running `etcdctl member remove`.
5. Adding it back by running `etcdctl member add`
6. Starting `etcd` with `--initial-cluster-state=existing` and cluster members listed in `--initial-cluster`.

### Restore whole cluster

Cluster can be restored by saving a snapshot from current leader and restoring it to all members.
Run `etcdctl snapshot save` against the leader and follow [restoring a cluster procedure](/docs/v3.5/op-guide/recovery).
