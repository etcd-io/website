---
title: "Etcd Patch Releases: v3.7.1, v3.6.14, and v3.5.33"
author: "SIG-Etcd Leads"
date: 2026-07-23
draft: false
---

SIG-etcd has released patch updates across all three supported release branches. These releases fix two security vulnerabilities, several minor security issues, and address several reliability issues in the server, client library, and TLS stack. Users on v3.5, v3.6, and v3.7 should update at the next scheduled maintenance window.

Obtain the updates here:

- [v3.7.1](https://github.com/etcd-io/etcd/releases/tag/v3.7.1)
- [v3.6.14](https://github.com/etcd-io/etcd/releases/tag/v3.6.14)
- [v3.5.33](https://github.com/etcd-io/etcd/releases/tag/v3.5.33)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

## Security Fix: watch responses leaked across RBAC key boundaries

All three releases fix a vulnerability where a user granted read permission on a single key could receive watch event notifications for every key starting from that key, exposing data beyond their authorized scope.

This vulnerability does not affect etcd as a part of the Kubernetes Control Plane. It only affects etcd clusters with Auth enabled in untrusted or partially trusted environments.

Users depending on etcd Auth in this way should update their clusters immediately. Other etcd users can update at the next regularly scheduled maintenance period.

More information on the vulnerability, including workarounds, may be found in [its vulnerability report](https://github.com/etcd-io/etcd/security/advisories/GHSA-xg4h-6gfc-h4m8)

### Acknowledgements

This vulnerability was reported by members of the etcd community. Our SIG is deeply thankful to:

- [Luis Toro](https://github.com/lobuhi)
- Anthropic and [Adam Korczynski](https://github.com/AdamKorcz)

If you find a vulnerability in etcd, please report it to [our security team](mailto:security@etcd.io).

## Security Fix: `tlsListener.acceptLoop` spawns unbounded handshake goroutines with no deadline

This patch release fixes a vulnerability where a network attacker could open, but not complete, an indefinite number of TLS client connections.  This would eventually exhaust etcd server resources, causing lack of availability.  This security vulnerability affects the Kubernetes control plane.

More information on the vulnerability, including workarounds, may be found in [its vulnerability report](https://github.com/etcd-io/etcd/security/advisories/GHSA-6vch-q96h-7gc3)

### Acknowledgements

This vulnerability was found, and patched, but members of the VMware by Broadcom team.  We are grateful to this team for helping keep etcd secure.

## Security and reliability fixes shared across all three releases

Beyond the two reported security fixes, all three releases include a set of fixes for both security and reliability of etcd:

- **Unbounded read on peer lease handler**: the HTTP handler for peer lease requests could perform an unbounded `io.ReadAll`, allowing a malicious or misbehaving peer to cause excessive memory use.  This has been fixed by capping the read.
- **Transaction cost accounting**: the `costTxnReq` function was not accounting for nested `RequestTxn` operations, which could cause request cost estimates to be inaccurate.
- **HTTP server timeouts**: a `ReadHeaderTimeout` is now set on the client-facing HTTP server, protecting against slow-header attacks that could hold connections open indefinitely.
- **Client `leaseCache` data race**: a concurrent map iteration over `leaseCache.entries` in `clientv3` was not properly synchronized, which could cause a panic or incorrect behavior under concurrent lease operations.
- **TLS handshake timeout**: the TLS listener in `client/pkg/v3` now sets a `tlsHandshakeTimeout`, preventing stalled TLS handshakes from holding connections open indefinitely.

v3.7.1 and v3.6.14 additionally fix a `snapshotLimitByte` configuration issue where the snapshot size limit was not initialized to a reasonable default, which could allow snapshots to grow without bound in some configurations.

## Dependency updates in v3.6.14 and v3.5.33

v3.6.14 and v3.5.33 update the Go compiler to [go 1.25.12](https://go.dev/doc/devel/release).

v3.5.33 also bumps `golang.org/x/net` to `v0.56.0` to address [GO-2026-5942](https://pkg.go.dev/vuln/GO-2026-5942) and `golang.org/x/text` to `v0.39.0` to address [GO-2026-5970](https://pkg.go.dev/vuln/GO-2026-5970).

Full changelogs for each release:

- [CHANGELOG-3.7.1](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md#v371)
- [CHANGELOG-3.6.14](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.6.md#v3614)
- [CHANGELOG-3.5.33](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#v3533)
