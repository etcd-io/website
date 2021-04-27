---
title: Latest Jepsen Results against etcd 3.4.3
date: 2020-01-30
author: Xiang Li
---

Jepsen tested and analyzed etcd 3.4.3, and had both good results and useful feedback to share with us.

A key part of etcd's design is strong consistency guarantees across the distributed key-value store. Kubernetes, Rook, OpenStack, and countless other critical software projects rely on etcd, in part, because of the etcd project's focus on reliability and correctness.

Over the years, the etcd team has put tremendous effort on building [testing](https://web.archive.org/web/20200811103145/https://coreos.com/blog/testing-distributed-systems-in-go.html) and [chaos engineering frameworks](https://web.archive.org/web/20200420035739/https://coreos.com/blog/new-functional-testing-in-etcd.html).  We feel that we've improved our consistency, and have asked Jepsen for validation.

[Jepsen](https://jepsen.io/) is the leading company testing open source distributed systems to check if they fulfill their consistency guarantees. They first tested etcd in version 0.4.1, and we have been using these findings ever since to improve our consistency. In this blog post, we share the overall positive results of the Jepsen analysis of etcd v3.4.3 as well as our plans to resolve the issues found in the analysis.

Funding for Jepsen's work was provided by the [Cloud Native Computing Foundation](https://www.cncf.io/), which hosts etcd.

## What went well

During the numerous failure cases created by Jepsen against an etcd cluster, it continued to perform as designed. From the analysis, the Jepsen author says:

> etcd 3.4.3 lived up to its claims for key-value operations: we observed nothing but strict-serializable consistency for reads, writes, and even multi-key transactions, during process pauses, crashes, clock skew, network partitions, and membership changes. Strict serializable behavior was the default for key-value operations.

> Watches appear correct, at least over single keys. So long as compaction does not destroy historical data while a watch isn't running, watches appear to deliver every update to a key in order.

Since Jepsen never "passes" software, but rather reports a lack of prohibitive issues, this is a great result from them. In general, it's much better than [other distributed databases](https://jepsen.io/analyses) tested to date.

We believe two factors contribute to this positive result to the rigorous Jepsen analysis:

### 1. A simple core

A simple solution to a problem space usually results in a robust system. As an example, etcd's Raft implementation is one of the simplest implementations in open source. It focuses on the core state machine of Raft and avoids wall-time and I/O handling in the core library. And, in its API, etcd supports multi-key transactions, but adopts a simple transactional model to keep the system easier to comprehend.

### 2. Rigorous testing practice

Early in the development cycle of etcd, we set a goal to [achieve 80% unit test line coverage](https://github.com/etcd-io/etcd/issues/1467) and 90% unit test line coverage over core components like Raft and the MVCC storage engine. As the project progressed, we put effort into ensuring logical path coverage for core components by [introducing fail points](https://github.com/etcd-io/gofail). To embrace the randomness of timing, OS scheduling and asynchronous network I/Os, we also developed continuous integration tests, which run 24x7, to try and produce issues on a running system in a way that unit tests simply cannot. These tests have increased the quality of etcd significantly.

## Identified Issues

Of course, no system undergoes Jepsen testing without them reporting some areas where it could be better.  etcd had a few:

### Lock Issues

One lock implementation issue was found during the test where etcd failed to check the ownership of the lock before the pending lock API call returned.

In etcd, a lock acquirer is associated with a session; the acquirer holds the lock until the session expires. When first attempting to acquire the lock, it may be held by someone else. In that case, the etcd server puts the acquirer into a queue, where it must wait until other lock holders release the lock. The problem is that the acquirer's session might expire during this wait time. The consequence of this premature expiration is that the etcd server must check the existence of the session again before returning to the API call.

### Documentation Issues

The Jepsen analysis not only covers software correctness but also verifies the documentation claims. The Jepsen author found documentation issues and misleading use case examples of etcd.  The previous etcd documentation on consistency and isolation is not clear and might cause confusion.

Our documentation describes the consistency model based on [the Wikipedia definition](https://en.wikipedia.org/wiki/Consistency_model), which is also the classification some etcd engineers [learned in University](http://www.cs.cmu.edu/~srini/15-446/S09/lectures/10-consistency.pdf). It also separates the isolation level from consistency level, as there is no general agreement on [how the two should be defined together](https://fauna.com/blog/demystifying-database-systems-part-4-isolation-levels-vs-consistency-levels).

The Jepsen author suggests etcd documentation adopt the term "strict serializability" originally defined in the [Linearizability paper published by Herlihy and Wing](https://web.archive.org/web/20201203054309/https://cs.brown.edu/~mph/HerlihyW90/p463-herlihy.pdf). After reading the documentation on other open source projects, as well as listening to feedback from our users, the etcd team agrees with the Jepsen author that the [suggested model and term](https://jepsen.io/consistency) are clearer and easier to understand.

Next, the lock API use case example is misleading and might cause runtime issues.

Like any other distributed lock system, an etcd lock provides different guarantees than say a local thread level lock. Specifically, an etcd lock only safely guarantees mutual exclusion inside etcd's own keyspace and transactions with revision checking. It provides weaker guarantee when accessing external resources with dependency on timing. Deadlock prevention and lock invalidation is difficult with distributed locks because a distributed lock does not protect resources within the same process, or even the same machine. To address this, distributed locks traditionally rely on a lease and heartbeat mechanism to detect disconnected lock holders and invalidate locks. When a lock holder is disconnected or paused without using revision checking (a fencing token implementation in etcd), it might access the protected resources simultaneously with the new lock holder. More details can be found [in Kleppmann's blog post](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html).

The etcd lock documentation fails to point out this difference and provides inaccurate examples of using the lock. We agree with the Jepsen team that the issues must be resolved, and etcd users should be informed with the accurate claims.

## Addressing Identified Issues

All the issues mentioned above are being addressed by the etcd team and the Jepsen team. Here is the list of issues and fixes. We appreciate feedback from community over these issues and help the etcd project become better.

| Analysis Issues | Github Issue | Status on 1/30 |
| -------------------- | ----- | --------- |
| Lock implementation | [11408](https://github.com/etcd-io/etcd/pull/11408) | Fixed
| Watch API defaulting documentation | [11496](https://github.com/etcd-io/etcd/issues/11496) | Fixed
| Consistency documentation | [11474](https://github.com/etcd-io/etcd/pull/11474) | Fixed
| Lock documentation | [11490](https://github.com/etcd-io/etcd/pull/11490) | Work in progress


## Future

Jepsen analysis is not a one time effort. During the analysis, the Jepsen team set up an extensive testing framework for the etcd project specifically. It also enables etcd team and the community to run those tests anytime and catch problems in the future.

We would love to see someone in the etcd community integrate the etcd Jepsen tests directly into the existing etcd release pipeline. We hope to ensure that all future releases of etcd are Jepsen tests approved.

Besides Jepsen analysis, etcd community always welcome contributions related to correctness and reliability. We are excited about the results of this testing, and will remain vigilant while building a well engineered and correct product.

To learn more read the full [Jepsen report for etcd 3.4.3](https://jepsen.io/analyses/etcd-3.4.3).
