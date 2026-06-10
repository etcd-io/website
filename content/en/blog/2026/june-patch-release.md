---
title: Final Update for v3.4, plus 3.5.31, 3.6.12 Released
author:  "SIG-Etcd Leads"
date: 2026-06-01
draft: false
---

SIG-etcd has released the final patch update for v3.4 together with security updates for v3.5 and v3.6.  Uses on v3.4 should begin the upgrade process as soon as possible.  Users on v3.5 and v3.6 should update at the next scheduled maintenance window.

Obtain all three updates here:

* [v3.6.12](https://github.com/etcd-io/etcd/releases/tag/v3.6.12)
* [v3.5.31](https://github.com/etcd-io/etcd/releases/tag/v3.5.31)
* [v3.4.45](https://github.com/etcd-io/etcd/releases/tag/v3.4.45)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

## Final v3.4 Release

This update marks the end of support (EOL) for v3.4, originally [released in August 2019](https://kubernetes.io/blog/2019/08/30/announcing-etcd-3-4/).  No further patches will be issued by the Kubernetes project.  If you are still using v3.4, please [upgrade to a supported version](https://etcd.io/docs/v3.6/upgrades/upgrade_3_5/) as soon as you can.

v3.4 introduced Learner nodes, better storage, performance Leases, concurrency-proof Leader failover, and a new client load balancer.  All of these are features that continue to make etcd the reliable, high-availability data store it is today.  With v3.7, though, a lot of that code has been replaced, and the project's ability to maintain v3.4 is increasingly difficult.

So say goodbye to v3.4, and prepare your upgrade scripts now.

## Patching multiple golang vulnerabilities in all versions

This release updates v3.4, v3.5 and v3.6 to [golang v1.25.10](https://github.com/etcd-io/etcd/issues/21725), which patches [multiple security vulnerabilities in go](https://groups.google.com/g/golang-nuts/c/QEttt5ZoGrE).  CVEs for patched vulnerabilities include the following: CVE-2026-42501, CVE-2026-39825, CVE-2026-39836, CVE-2026-42499, CVE-2026-39820, CVE-2026-39819, CVE-2026-39817, CVE-2026-33814, CVE-2026-39826, CVE-2026-33811, and CVE-2026-39823.  It is unknown how many of these vulnerabilities are exploitable in etcd, but users should plan to apply the patch as soon as convenient regardless.

If you find a vulnerability in etcd, please report it to [our security team](mailto:security@etcd.io).

This release also fixes several reliability issues, which can be found in the [changelog](https://github.com/etcd-io/etcd/releases/tag/v3.6.12)
