---
title: Granting and revoking leases
description: Guide to granting and revoking leases in etcd
weight: 700
---

## Prerequisites

- A running etcd cluster (see [getting started](/docs/v3.5/quickstart/))
- `etcdctl` installed and configured

The following variables are used in this guide:

- `$ENDPOINTS` — the etcd endpoint(s), e.g. `localhost:2379`
- `lease grant` — creates a new lease with a TTL (time-to-live) in seconds
- `put --lease` — attaches a key to a lease so it expires with it
- `lease keep-alive` — refreshes a lease to prevent it from expiring
- `lease revoke` — immediately expires a lease and deletes its keys

For more information on leases, see [Interacting with etcd: Grant leases](/docs/v3.5/dev-guide/interacting_v3/#grant-leases).

## Grant a lease

Grant a lease with a TTL of 300 seconds:

```bash
etcdctl --endpoints=$ENDPOINTS lease grant 300
# lease 2be7547fbc6a5afa granted with TTL(300s)
```

Attach a key to the lease so it is automatically deleted when the lease expires:

```bash
etcdctl --endpoints=$ENDPOINTS put sample value --lease=2be7547fbc6a5afa
etcdctl --endpoints=$ENDPOINTS get sample
```

Keep the lease alive by refreshing it before it expires:

```bash
etcdctl --endpoints=$ENDPOINTS lease keep-alive 2be7547fbc6a5afa
```

## Revoke a lease

Revoke the lease immediately, which also deletes all keys attached to it:

```bash
etcdctl --endpoints=$ENDPOINTS lease revoke 2be7547fbc6a5afa
```

After revocation (or after the TTL expires), the key is no longer accessible:

```bash
etcdctl --endpoints=$ENDPOINTS get sample
# (empty response)
```