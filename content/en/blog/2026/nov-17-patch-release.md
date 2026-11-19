---
title: "etcd Patch Releases: v3.7.4, v3.6.17, v3.5.36"
author: "SIG-Etcd Leads"
date: 2026-11-17
draft: false
---

SIG-etcd has published patch releases for all three supported versions of etcd v3.7.4, v3.6.17 and v3.5.36. These updates improve recovery behavior and concurrency safety, and include additional version-specific fixes. Users should update at the next scheduled maintenance window after the releases become available.

Updates may be found here:

- [v3.7.4](https://github.com/etcd-io/etcd/releases/tag/v3.7.4)
- [v3.6.17](https://github.com/etcd-io/etcd/releases/tag/v3.6.17)
- [v3.5.36](https://github.com/etcd-io/etcd/releases/tag/v3.5.36)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

## Recovery and concurrency fixes

All three releases fix an issue where using `--force-new-cluster` could permanently prevent a member from starting when the backend's consistent index was ahead of the last index in its write-ahead log (WAL). The fix prevents the adjusted commit index from exceeding the WAL's last index.

The releases also define `alarmStore` as an `atomic.Pointer`, fixing a race condition when accessing the active alarm store.

## Version-specific fixes

v3.7.4 fixes a startup panic that could occur while replaying legacy v2 member-attribute entries from the WAL.

v3.5.36 fixes an issue where a leader that removed itself from the cluster could answer a `ReadIndex` request with a stale index.

## Dependency updates

All three releases are built with [Go 1.26.11](https://go.dev/doc/devel/release). Official container images now use Debian 13.7, which [distrusts eMudhra certificates](https://emudhra.we-have-a-problem.com/).

v3.7.4 and v3.6.17 update `golang.org/x/net` to v0.62.0, addressing [CVE-2026-78661](https://github.com/advisories/GHSA-75pg-wvh3-34jr) and [CVE-2026-97045](https://github.com/advisories/GHSA-vwcj-r8v9-p53f).

Additionally, v3.6.17 also updates `github.com/klauspost/compress` to v1.20.2 to address [CVE-2026-116591](https://pkg.go.dev/vuln/GO-2026-6865).

For the full list of changes, see the changelogs:

- [v3.7.4](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md#v374-tbc)
- [v3.6.17](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.6.md#v3617-tbc)
- [v3.5.36](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#v3536-tbc)
