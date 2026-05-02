---
title: May 1 Security Release Patches RBAC Bypass in Transactions
author: SIG-etcd Security Team
date: 2026-05-02
---

SIG-etcd released updates [v3.6.11](https://github.com/etcd-io/etcd/releases/tag/v3.6.11), [v3.5.30](https://github.com/etcd-io/etcd/releases/tag/v3.5.30), and [v3.4.44](https://github.com/etcd-io/etcd/releases/tag/v3.4.44) today. These patch releases fix a vulnerability that allows an authenticated user to bypass RBAC authorization checks when reading data via `PrevKv` or attaching leases inside `Put` requests nested in etcd transactions.

In addition, v3.6.11 and v3.5.30 contain a bug fix for an issue that prevented adding a new member when one member was down, even though quorum was still satisfied.

This vulnerability does not affect etcd as a part of the Kubernetes Control Plane.  Kubernetes does not rely on etcd's built-in authentication and authorization; the API server handles authentication and authorization itself. The issue only affects etcd clusters in other contexts, specifically ones with Auth enabled where it is required for access control in untrusted or partially trusted networks or with untrusted users.

Users depending on etcd Auth in this way should update their clusters immediately.  Other etcd users can update at the next regularly scheduled maintenance period.

**EOL Notice**: etcd 3.4 is scheduled to be EOL in May 2026.  If you are still using version 3.4, please start planning your upgrade now.

More information on the vulnerability:

* [RBAC authorization bypass in etcd allows unauthorized data access via PrevKv or lease attachment in Put requests nested in transactions](https://github.com/etcd-io/etcd/security/advisories/GHSA-x35m-3gp4-4fh5)

This issue has been rated `Low`, with CVSS `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N`.

## Workarounds

If upgrading is not immediately possible, reduce exposure by treating the affected RPCs as unauthenticated in practice:

* Restrict network access to etcd server ports so only trusted components can connect.
* Require strong client identity at the transport layer, such as mTLS with tightly scoped client certificate distribution.

## Acknowledgements

This vulnerability was reported by members of the etcd community.  Our SIG is deeply thankful to:

* Samy Ghannad ([@SamyGhannad](https://github.com/SamyGhannad)) for reporting that read access via `PrevKv` in a `Put` request within etcd transactions bypassed RBAC authorization checks.
* Benjamin Wang ([@ahrtr](https://github.com/ahrtr)) for further analyzing that lease attachment in a `Put` request within etcd transactions also bypassed RBAC authorization checks.

If you find a vulnerability in etcd, please report it to [our security team](mailto:security@etcd.io).
