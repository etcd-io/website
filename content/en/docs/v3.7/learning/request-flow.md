---
title: Request flow
weight: 2200
description: How client requests flow through an etcd cluster
---

This page describes how an etcd cluster handles a client request, from the moment it arrives at a member until the response is returned.
It covers write requests handled by the leader, write requests sent to a follower, and the two kinds of read requests.

{{% alert color="info" %}}

**Note**: The diagrams on this page were created in September 2023, when etcd v3.5 was the latest stable release.
The overall flow is stable across versions, but implementation details may have changed since then.
The diagram sources are maintained in the [etcd-internals directory][diagram-source] of the etcd repository.

{{% /alert %}}

## Leaders and followers

An etcd cluster normally consists of multiple members, typically three or five.
The members use the [Raft consensus algorithm][raft] to elect a leader; the other voting members are followers.
The leader handles all requests that need cluster consensus, such as writes.
A client does not need to know which member is the leader: it can connect to any member, and any request that needs consensus is automatically forwarded to the leader.
Reads that do not need consensus (serializable reads) can be served by any member from its local data.
See also the [FAQ entry][faq-leader] on this question.

## Inside an etcd member

Every member runs the same set of components:

![Figure 1: the internal parts of an etcd member](../img/request-flow-figure-01.png)

* The **gRPC server** is the entry point for client requests such as `Put` and `Range`.
* The **etcd server** main loop coordinates each request between the other components.
* The **raft subsystem** reaches consensus on proposals with its peers over the peer network (Raft HTTP) and persists log entries in a write ahead log (WAL) on disk.
* The **MVCC store** holds the key-value data, including previous revisions of each key, and persists it on disk using [bbolt][bbolt] (labeled BoltDB in the diagrams).

See [etcd persistent storage files][storage] for more detail on the WAL and the bbolt backend.
The following sections show how a request travels through these components.

## Write request handled by the leader

*Figure 2* shows a write request, for example a `Put`, that arrives directly at the leader (the diagrams label members as nodes):

![Figure 2: write request handled by the leader](../img/request-flow-figure-02.png)

1. The client's write request arrives at the leader's gRPC endpoint.
2. The etcd server forwards the request to its raft subsystem as a proposal.
3. The raft subsystem persists the proposal to the leader's own WAL and, in parallel, asks its peers (over HTTP) to replicate it.
4. Each follower persists the proposal to its own WAL.
5. Each follower confirms the replication to the leader.
6. As soon as a quorum (majority) of the members, counting the leader itself, has persisted the proposal, the leader marks the transaction as committed.
7. The raft subsystem notifies the etcd server that the entry is committed and can be applied.
8. The etcd server applies the entry to the MVCC store and backend.
9. The etcd server returns a gRPC success response to the client.

Two things happen asynchronously and do not delay the response to the client.
After step 6 the leader tells the followers that the transaction is committed, so each follower applies the entry to its own MVCC store as well.
And the MVCC store syncs the bbolt file on disk in the background, so persisting the backend does not block the write path; durability is already guaranteed by the WAL.

## Write request sent to a follower

*Figure 3* shows what happens when a write request arrives at a follower instead of the leader:

![Figure 3: write request sent to a follower](../img/request-flow-figure-03.png)

1. The client's write request arrives at the follower's gRPC endpoint.
2. The etcd server forwards the request to its raft subsystem.
3. The follower's raft subsystem forwards the write request to the leader.
4. The leader persists the proposal to its own WAL and, in parallel, asks its peers to replicate it.
5. The follower persists the proposal to its own WAL.
6. The follower confirms the replication to the leader.
7. Once a quorum has persisted the proposal, the leader confirms the transaction as committed to the follower.
8. The follower's raft subsystem marks the transaction as committed.
9. The raft subsystem notifies the etcd server that the entry can be applied.
10. The etcd server applies the entry to the MVCC store and backend.
11. The etcd server returns a gRPC success response to the client.

The flow is the same as in the previous section, except that the proposal takes one extra network hop to reach the leader (step 3), and the follower waits for the leader's commit confirmation (step 7) before it can apply the entry and respond.

## Linearizable read

By default, etcd reads are linearizable: a read reflects the latest committed state of the cluster at the time the request is served.
Serving a linearizable read from a member's local data alone would be unsafe, because that member might be lagging behind the leader or might have been partitioned away from the cluster.
Instead of routing reads through full consensus, etcd uses the Raft *ReadIndex* mechanism, shown in *Figure 4* for a read that arrives at a follower:

![Figure 4: linearizable read served by a follower](../img/request-flow-figure-04.png)

1. The client's range request arrives at the member's gRPC endpoint.
2. The etcd server creates a unique request ID for tracking and blocks until the raft subsystem confirms the read is safe to serve.
3. The member's raft subsystem requests an up-to-date read index from the leader.
4. The leader sends a heartbeat to the followers to confirm through a quorum that it is still the leader.
5. The leader sends its read index, which is its current committed index.
6. The raft subsystem hands the read index back to the etcd server, together with a channel that blocks until the member's applied entries catch up with it.
7. The etcd server waits until all entries up to the read index have been applied to the MVCC store.
8. The etcd server asks the MVCC store for the key-values matching the range request.
9. The MVCC store computes the result from its now up-to-date data and returns it.
10. The etcd server serves the response to the client.

A linearizable read never returns stale data, at the cost of one round trip to the leader plus a quorum heartbeat.
See [etcd API guarantees][api-guarantees] for the formal definitions.

## Serializable read

A serializable read skips steps 3 through 7 above: the member serves the request directly from its local MVCC store, without consulting the leader.
This makes serializable reads cheaper and keeps them available even when the member is partitioned from the rest of the cluster, but the response may be stale if the member has not yet applied the latest committed entries.
Clients opt into serializable reads per request, for example with `etcdctl get --consistency=s`.

## Further reading

* A maintainer's [CNCF presentation on etcd internals][internals-presentation], with additional diagrams of the storage layer.
* [The Raft consensus algorithm][raft] and the [Raft paper][raft-paper].
* [etcd API guarantees][api-guarantees] for the consistency model these flows implement.
* [etcd persistent storage files][storage] for the on-disk formats of the WAL and the bbolt backend.

[api-guarantees]: ../api_guarantees/
[bbolt]: https://github.com/etcd-io/bbolt
[diagram-source]: https://github.com/etcd-io/etcd/tree/main/Documentation/etcd-internals/diagrams
[faq-leader]: ../../faq/#do-clients-have-to-send-requests-to-the-etcd-leader
[internals-presentation]: https://github.com/ahrtr/etcd-issues/blob/master/docs/cncf_storage_tag_etcd.md
[raft]: https://raft.github.io/
[raft-paper]: https://raft.github.io/raft.pdf
[storage]: ../persistent-storage-files/
