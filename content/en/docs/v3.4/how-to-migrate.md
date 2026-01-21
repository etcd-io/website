---
title: How to migrate etcd from v2store to v3store
description: etcd v2store to v3store migration guide
weight: 1200
---

`migrate` to transform etcd v2store to v3store.

Learn more about the difference between the [etcd data storage format](https://etcd.io/docs/v3.6/learning/data_model/) and the [etcd versioning](https://etcd.io/docs/v3.6/op-guide/versioning/).

etcd v2.Y releases store data in the v2store, which supports the legacy API v2. When upgrading to etcd v3.Y releases, the cluster may continue to carry this v2store data until it is explicitly migrated into the newer v3store, which is required for full API v3 support and long-term compatibility.

This document focus on how to migrate existing data from the v2store to the v3store. For a detailed guideline of migrating from API v2 to API v3, please refer to [Migrate applications from using API v2 to API v3](https://etcd.io/docs/v3.4/op-guide/v2-migration/).

{{% alert color="warning" %}}
⚠️ **Deprecated functionality:**

The `etcdctl migrate` command was removed in etcd v3.5.0 ([pull/12971](https://github.com/etcd-io/etcd/pull/12971)). If your etcd cluster is already running v3.5 or higher, you can no longer migrate v2store to v3store using this method.  

You **must use etcdctl v3.4 or earlier** to perform the migration (View note from  [CHANGELOG-3.5](https://github.com/ahrtr/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#etcdctl-v3-3)). However please take appropriate precautions when using it, as it is no longer officially supported or tested in recent releases.  
{{% /alert %}}

## Pre-requisites

Before migrating from etcd v2store to v3store, make sure you have:

- An etcd cluster that still contains v2store data.
- The `etcdctl` CLI version 3.4 or earlier.
- Access to each etcd node and their data directories.
- A working backup of your etcd data before performing the migration.

## Migrate a cluster

The following steps show how to migrate your etcd data stored from v2store to v3store using `etcdctl migrate`.

### Variables and Flags Used

- `--endpoints`: Specifies the etcd cluster endpoint(s).
- `--output`: Output format (e.g., `"json"`).
- `--data-dir`: Path to the data directory (default: `default.etcd`). View more at [etcd flags](https://etcd.io/docs/v3.6/op-guide/configuration/#member).
- `--wal-dir`: The write-ahead log (WAL) directory inside `data-dir` (default: `default.etcd/member/wal`). View more at [etcd flags](https://etcd.io/docs/v3.6/op-guide/configuration/#member).
- `set`: Command to set a key-value pair in etcd v2store (View [READMEv2](https://github.com/etcd-io/etcd/blob/main/etcdctl/READMEv2.md#setting-key-values) for more details. In etcd v3, the equivalent command is `put` instead of `set`, see the [READMEv3](https://github.com/etcd-io/etcd/tree/main/etcdctl#key-value-commands)) for reference.
- `get`: Command to retrieve a key-value pair (View [Read keys](https://etcd.io/docs/v3.6/dev-guide/interacting_v3/#read-keys)).

### Migration Process

#### Step 1: Write a test key into the v2store and confirm that key exists

```sh
export ETCDCTL_API=2
etcdctl --endpoints=http://$ENDPOINT set foo bar
etcdctl --endpoints=http://$ENDPOINT --output="json" get foo
```

#### Step 2: Stop each etcd node (one at a time)

Before running the migration, stop your etcd node to ensure data consistency.

#### Step 3: Run the migration tool to convert v2store to v3store

Switch to API v3 and use `etcdctl migrate` command to transform the v2store data into v3store. Please review the deprecation alert on top of the page, you must use etcdctl v3.4 or earlier to be able to perform this command.

```sh
export ETCDCTL_API=3
etcdctl --endpoints=http://$ENDPOINT migrate \
  --data-dir="default.etcd" \
  --wal-dir="default.etcd/member/wal"
```

#### Step 4: Restart etcd node after migrate

Repeat steps 2–4 for each etcd node one at a time in your cluster.

#### Step 5: Confirm the key is now stored in v3store

Use the API v3 to check:

```sh
etcdctl --endpoints=$ENDPOINTS get /foo
```

If the migration succeeded, you should see the value previously stored in v2store.

#### Summary full process

```shell
# Write key in etcd version 2store
export ETCDCTL_API=2
etcdctl --endpoints=http://$ENDPOINT set foo bar

# Confirm key exists in v2store
etcdctl --endpoints=$ENDPOINTS --output="json" get foo

# Stop etcd node to migrate, one by one

# Migrate v2store to v3store
export ETCDCTL_API=3
etcdctl --endpoints=$ENDPOINT migrate --data-dir="default.etcd" --wal-dir="default.etcd/member/wal"

# Restart etcd node after migrate and repeat the previous process for each node.

# Confirm the key was migrated into v3store
etcdctl --endpoints=$ENDPOINTS get /foo
```
