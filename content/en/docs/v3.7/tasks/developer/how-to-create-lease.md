---
title: Granting and revoking leases
description: Guide to granting and revoking leases in etcd
weight: 700
---

A lease is a time-to-live (TTL) that keys can be attached to. When the lease
expires or is revoked, etcd automatically deletes every key attached to it.

## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.7/install/).
* A running `etcd` cluster.

## Terminology

Here are definitions of the commands and flags used in the examples below.

| Term | Definition |
| --- | --- |
| `--endpoints` | A comma-delimited list of machine addresses in the cluster, for example `localhost:2379`. |
| `lease grant` | Creates a new lease with a TTL, given in seconds. Returns a lease ID. |
| `put` | Writes a value to a key. |
| `value` | The value written to the key in the examples below. |
| `--lease` | Attaches a key to a lease, so the key is deleted when the lease expires. |
| `get` | Reads the value of a key. |
| `lease keep-alive` | Refreshes a lease so that it does not expire. |
| `lease revoke` | Expires a lease immediately, deleting all keys attached to it. |

For more information on leases, see
[Interacting with etcd: Grant leases](https://etcd.io/docs/v3.7/dev-guide/interacting_v3/#grant-leases).

## Grant a lease

![07_etcdctl_lease_2016050501](https://storage.googleapis.com/etcd/demo/07_etcdctl_lease_2016050501.gif)

Grant a lease with a TTL of 300 seconds:

```shell
etcdctl --endpoints=$ENDPOINTS lease grant 300
# lease 2be7547fbc6a5afa granted with TTL(300s)
```

Attach a key to the lease, so that the key is deleted when the lease expires:

```shell
etcdctl --endpoints=$ENDPOINTS put sample value --lease=2be7547fbc6a5afa
etcdctl --endpoints=$ENDPOINTS get sample
```

Keep the lease alive by refreshing it before it expires:

```shell
etcdctl --endpoints=$ENDPOINTS lease keep-alive 2be7547fbc6a5afa
```

## Revoke a lease

Revoke the lease immediately. This also deletes every key attached to it:

```shell
etcdctl --endpoints=$ENDPOINTS lease revoke 2be7547fbc6a5afa
```

After the lease is revoked, or after its TTL expires, the attached key is gone:

```shell
etcdctl --endpoints=$ENDPOINTS get sample
# (empty response)
```
