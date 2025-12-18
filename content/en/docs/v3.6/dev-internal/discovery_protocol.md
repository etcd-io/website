---
title: Discovery service protocol
weight: 1500
description: Discover other etcd members in a cluster bootstrap phase
---

Discovery service protocol helps new etcd member to discover all other members in cluster bootstrap phase using a shared discovery token and endpoint list.

Discovery service protocol is _only_ used in cluster bootstrap phase, and cannot be used for runtime reconfiguration or cluster monitoring.

The protocol uses a new discovery token to bootstrap one _unique_ etcd cluster. Remember that one discovery token can represent only one etcd cluster. As long as discovery protocol on this token starts, even if it fails halfway, it must not be used to bootstrap another etcd cluster.

The rest of this article will walk through the discovery process with examples that correspond to a self-hosted discovery cluster.

Note that this document is only for v3 discovery. Check previous document for more details on [v2 discovery][v2-discovery].

## Protocol workflow

The idea of discovery protocol is to use an internal etcd cluster to coordinate bootstrap of a new cluster. First, all new members interact with discovery service and help to generate the expected member list. Then each new member bootstraps its server using this list, which performs the same functionality as -initial-cluster flag.

In the following example workflow, we will list each step of protocol using `etcdctl` command for ease of understanding, and we assume that `http://example.com:2379` hosts an etcd cluster for discovery service.

By convention the etcd discovery protocol uses the key prefix `/_etcd/registry`.


### Creating a new discovery token

Generate a unique token that will identify the new cluster. This will be used as a unique prefix in discovery keyspace in the following steps. An easy way to do this is to use `uuidgen`:

```
UUID=$(uuidgen)
```

### Specifying the expected cluster size

The discovery token expects a cluster size that must be specified. The size is used by the discovery service to know when it has found all members that will initially form the cluster.

```
etcdctl --endpoints=http://example.com:2379 put /_etcd/registry/${UUID}/_config/size ${cluster_size}
```

Usually the cluster size is 3, 5 or 7. Check [optimal cluster size][cluster-size] for more details.

### Bringing up etcd processes

Set the discovery token `${UUID}` to `--discovery-token` flag, and set the endpoints of the etcd cluster backing the discovery service to `--discovery-endpoints` flag. This will enable v3 discovery to bootstrap the etcd cluster.

Every etcd process will follow the next few steps internally if `--discovery-token` and `--discovery-endpoints` flags are given.

If the discovery service enables client cert authentication, configure the following flags. They follow exactly the same usage as using `etcdctl` to communicate with an etcd cluster.
```
--discovery-insecure-transport
--discovery-insecure-skip-tls-verify
--discovery-cert
--discovery-key
--discovery-cacert
```

If the discovery service enables role based authentication, configure the following flags. They follow exactly the same usage as using `etcdctl` to communicate with an etcd cluster.
```
--discovery-user
--discovery-password
```

The default time or timeout values can also be changed using the following flags, which follow exactly the same usage as using `etcdctl` to communicate with an etcd cluster.
```
--discovery-dial-timeout
--discovery-request-timeout
--discovery-keepalive-time
--discovery-keepalive-timeout
```

### Registering itself

The first thing that each etcd process does is to register itself into the given new cluster as a member. This is done by creating member ID as a key in the full registry key.

```
etcdctl --endpoints=http://example.com:2379 put /_etcd/registry/${UUID}/members/${member_id} ${member_name}=${member_peer_url_1}&${member_name}=${member_peer_url_2}
```

### Checking the status

It checks the expected cluster size and registration status, and decides what the next action is.

```
etcdctl --endpoints=http://example.com:2379 get /_etcd/registry/${UUID}/_config/size
etcdctl --endpoints=http://example.com:2379 get /_etcd/registry/${UUID}/members
```

If registered members are still not enough, it will wait for other members to appear.

If the number of registered members is bigger than the expected size N, it treats the first N registered members as the member list for the cluster. If the member itself is in the member list, the discovery procedure succeeds, and it fetches all peers through the member list. If it is not in the member list, the discovery procedure finishes with the failure that the cluster has been full.

The member may check the cluster status even before registering itself. So it could fail quickly if the cluster has been full.

### Waiting for all members

The wait process keeps watching the key prefix `/_etcd/registry/${UUID}/members` until finding all members.

```
etcdctl --endpoints=http://example.com:2379 watch /_etcd/registry/${UUID}/members --prefix
```

[v2-discovery]: /docs/v3.5/dev-internal/discovery_protocol
[cluster-size]: /docs/v2.3/admin_guide#optimal-cluster-size
[expected-cluster-size]: #specifying-the-expected-cluster-size
[new-discovery-token]: #creating-a-new-discovery-token
