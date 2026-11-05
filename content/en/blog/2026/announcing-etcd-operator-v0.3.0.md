---
title: Announcing etcd-operator v0.3.0
author:  "WG etcd-operator Organizers"
date: 2026-11-06
draft: false
---

Today we are proud to announce the release of [etcd-operator v0.3.0].  This release represents a substantial rewrite of the operator code in order to move from StatefulSet to a custom controller that can handle more failure conditions.

Versions v0.1.0 and v0.2.0 were built with a CRD backed by the StatefulSet workload.  The team found that certain limitations and assumptions in StatefulSet made it very difficult to recover individual failed cluster members, or manually recover from a failed cluster.  Our contributors rewrote the operator to use a custom controller instead, and expanded and [updated the workflow logic][workflow] to handle various kinds of cluster failures.

In the course of this, we also determined the order of application for cluster configuration changes, and expanded E2E testing in order to check failure and recovery.  etcd clusters managed by v0.3.0 are now capable of self-healing from losing a member, CORRUPT and NOSPACE alarms, and being restored with intervention after losing quorum.  We've also expanded health check information and added status reporting.

Follow the [installation instructions](https://github.com/etcd-io/etcd-operator/blob/main/docs/install.md) to try out the operator.

## Contributors

The WG thanks ongoing operator contributors @ahrtr, @nwnt, @ArkaSaha30, @silentred, @GunaKKIBM, and @ivanvc for the changes in this release.

We welcome new contributors @harsha3330, @fuweid, @anhtranbk, @pjsharath28, @valen-mascarenhas14, @AR21SM, @charankooram, @Kitio-Tek, and @Batianxieshen1 who helped create v0.3.0.

Please [join us] and help us finish the operator!

[etcd-operator v0.3.0]: https://github.com/etcd-io/etcd-operator/releases/tag/v0.3.0
[workflow]: https://github.com/etcd-io/etcd-operator/blob/main/docs/design/etcd-member-lifecycle-and-self-healing-v0.3.0.md
[join us]: https://github.com/etcd-io/etcd-operator/blob/main/CONTRIBUTING.md
