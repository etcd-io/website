---
title: "Etcd Patch Releases: v3.7.2, v3.6.15, and v3.5.34"
author: "SIG-Etcd Leads"
date: 2026-09-22
draft: false
---

SIG-etcd has distributed patch updates for all three supported release branches. These releases update dependencies, fix a file-handle leak during file cleanup, correct `etcdctl endpoint status` output, and improve version detection in v3.7. Users on v3.5, v3.6, and v3.7 should update at the next scheduled maintenance window after the releases become available.

Obtain the updates here:

- [v3.7.2](https://github.com/etcd-io/etcd/releases/tag/v3.7.2)
- [v3.6.15](https://github.com/etcd-io/etcd/releases/tag/v3.6.15)
- [v3.5.34](https://github.com/etcd-io/etcd/releases/tag/v3.5.34)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

## Dependency security updates

v3.6.15 and v3.5.34 update `github.com/gorilla/websocket` to v1.5.3 to [address a weak cryptography issue](https://github.com/advisories/GHSA-w67g-5rqw-f597) (no CVE is yet allocated).

v3.6.15 also updates `golang.org/x/text` to v0.39.0 to address [CVE-2026-56852](https://pkg.go.dev/vuln/GO-2026-5970).

All three releases compile binaries using [Go 1.26.8](https://go.dev/doc/devel/release).

## Close locked files after purge failures

All three releases fix a file-handle and advisory-lock leak in [`purgeFile`](https://github.com/etcd-io/etcd/pull/22452). If removing a locked file failed, `purgeFile` previously returned without closing the file. It now closes the locked file before returning the removal error and logs any error encountered while closing it.

## Correct `etcdctl endpoint status` output

All three releases fix a duplicate `RaftTerm` field in the output of `etcdctl endpoint status --write-out=fields`. The command now reports the field only once, making its field-formatted output easier for users and automation to consume.

## More accurate version detection in v3.7.2

v3.7.2 updates [`MinimalEtcdVersion`](https://github.com/etcd-io/etcd/pull/22201) to read the latest snapshot entry from the write-ahead log (WAL). This prevents an error where an upgraded etcd cluster might read a v2 snapshot instead of a v3 one.

Full changelogs for each release:

- [CHANGELOG-3.7.2](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md#v372-tbc)
- [CHANGELOG-3.6.15](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.6.md#v3615-tbc)
- [CHANGELOG-3.5.34](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#v3534-tbc)
