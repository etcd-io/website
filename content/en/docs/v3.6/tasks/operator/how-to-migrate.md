---
title: How to migrate etcd from v2 to v3
description: etcd v2 to v3 migration guide
weight: 1200
---

`migrate` to transform etcd v2 data model to v3 data model.

{{% alert color="warning" %}}
⚠️ **Deprecated functionality:**

The `etcdctl migrate` command was removed in etcd v3.5.0 ([pull/12971](https://github.com/etcd-io/etcd/pull/12971)). If your etcd cluster is already running v3.5 or higher, you can no longer migrate v2 data to v3 using this method.  

You **must use etcdctl v3.4 or earlier** to perform the migration ([CHANGELOG-3.5](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#etcdctl-v3-3)). However please take appropriate precautions when using it, as it is no longer officially supported or tested in recent releases.  
{{% /alert %}}

## Pre-requisites

Before migrating from etcd v2 to v3, ensure the following:

- A currently running etcd v2 cluster.
- The `etcdctl` CLI tool version <= v3.4.
- Access to each etcd node and their data directories.
- A working backup of your etcd data before performing the migration.

## Migrate a cluster

The following steps show how to migrate your etcd data from v2 to v3 using `etcdctl migrate`.

### Variables and Flags Used

- `--endpoints`: Specifies the etcd cluster endpoint(s).
- `--output`: Output format (e.g., `"json"`).
- `--data-dir`: Path to the data directory (default: `default.etcd`). View more at [etcd flags](https://etcd.io/docs/v3.6/op-guide/configuration/#member).
- `--wal-dir`: The write-ahead log directory inside `data-dir` (default: `default.etcd/member/wal`). View more at [etcd flags](https://etcd.io/docs/v3.6/op-guide/configuration/#member).
- `set`: Command to set a key-value pair in etcd v2 (View [READMEv2](https://github.com/etcd-io/etcd/blob/main/etcdctl/READMEv2.md#setting-key-values) for more details. In etcd v3, the equivalent command is `put` instead of `set`, see the [READMEv3](https://github.com/etcd-io/etcd/tree/main/etcdctl#key-value-commands)) for reference.
- `get`: Command to retrieve a key-value pair (View [Read keys](https://etcd.io/docs/v3.6/dev-guide/interacting_v3/#read-keys)).

### Migration Process

- Step 1: Set up test key using v2 API

```sh
export ETCDCTL_API=2
etcdctl --endpoints=http://$ENDPOINT set foo bar
etcdctl --endpoints=http://$ENDPOINT --output="json" get foo
```

- Step 2: Stop each etcd node (one at a time)

Before running the migration, stop your etcd node to ensure data consistency.

- Step 3: Run the migration tool

Switch to API v3 and use etcdctl migrate to transform the v2 store.

```sh
export ETCDCTL_API=3
etcdctl --endpoints=http://$ENDPOINT migrate \
  --data-dir="default.etcd" \
  --wal-dir="default.etcd/member/wal"
```

- Step 4: Restart etcd node after migrate
Repeat steps 2–4 for each etcd node one at a time in your cluster.

- Step 5: Confirm the data is accessible via v3 API

```sh
etcdctl --endpoints=$ENDPOINTS get /foo
```

Summary full process:

```shell
# write key in etcd version 2 store
export ETCDCTL_API=2
etcdctl --endpoints=http://$ENDPOINT set foo bar

# read key in etcd v2
etcdctl --endpoints=$ENDPOINTS --output="json" get foo

# stop etcd node to migrate, one by one

# migrate v2 data
export ETCDCTL_API=3
etcdctl --endpoints=$ENDPOINT migrate --data-dir="default.etcd" --wal-dir="default.etcd/member/wal"

# restart etcd node after migrate, one by one

# confirm that the key got migrated
etcdctl --endpoints=$ENDPOINTS get /foo
```

## Visual guide for reference

![12_etcdctl_migrate_2016061602](https://storage.googleapis.com/etcd/demo/12_etcdctl_migrate_2016061602.gif)
