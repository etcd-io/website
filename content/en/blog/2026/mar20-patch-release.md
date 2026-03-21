---
title: March 20 Security Release Patches Auth Vulnerabilities
author:  SIG-etcd Security Team
date: 2026-03-20
---

SIG-etcd released updates [3.6.9](https://github.com/etcd-io/etcd/releases/tag/v3.6.9), [3.5.28](https://github.com/etcd-io/etcd/releases/tag/v3.5.28), and [3.4.42](https://github.com/etcd-io/etcd/releases/tag/v3.4.42) today.  These patch releases fix several vulnerabilities which allow unauthorized users to bypass authentication or authorization controls that are part of etcd Auth using the gRPC API.

These vulnerabilities do not affect etcd as a part of the Kubernetes Control Plane.  They only affect etcd clusters in other contexts, specifically ones with Auth enabled where it is required for access control in untrusted or partially trusted networks or with untrused users.

Users depending on etcd Auth in this way should update their clusters immediately.  Other etcd users can update at the next regularly scheduled maintenance period.

**EOL Notice**: etcd 3.4 is scheduled to be EOL in May 2026.  If you are still using version 3.4, please start planning your upgrade now.

More information on the vulnerabilities:

* CVE-2026-33413: [Authorization bypasses in multiple APIs](https://github.com/etcd-io/etcd/security/advisories/GHSA-q8m4-xhhv-38mg)
* CVE-2026-33343: [Nested etcd transactions bypass RBAC authorization checks](https://github.com/etcd-io/etcd/security/advisories/GHSA-rfx7-8w68-q57q)

Both issues have been rated Moderate.with CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N.

All of these vulnerabilies were reported by members of the etcd community.  Our SIG is deeply thankful to:

* Isaac David from bugbunny.ai
* Asim Viladi Oglu Manizada
* Alex Schapiro & Ahmed Allam from Strix security (strix.ai)
* Luke Francis
* @OLU-DEVX
* Battulga Byambaa

If you find a vulnerability in etcd, please report it to [our security team](mailto:security@etcd.io).
