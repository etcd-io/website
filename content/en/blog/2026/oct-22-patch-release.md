---
title: "etcd Patch Releases: v3.7.3, v3.6.16, v3.5.35"
author: "SIG-Etcd Leads"
date: 2026-10-22
draft: false
---

SIG-etcd has published patch releases for all three supported versions of etcd.  These updates fix multiple public security vulnerabilities, as well as several other operational issues.  Users should update etcd as soon as reasonably possible.

Updates may be found here:

- [v3.7.3](https://github.com/etcd-io/etcd/releases/tag/v3.7.3)
- [v3.6.16](https://github.com/etcd-io/etcd/releases/tag/v3.6.16)
- [v3.5.35](https://github.com/etcd-io/etcd/releases/tag/v3.5.35)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

SIG etcd has received additional issue reports recently that are not patched in this release.  However, this update fixes known, public security vulnerabilities as well as serious perfomance problems currently affecting users.  As such, we decided to release an update now with the understanding that additional patch releases will be required soon.

## Security Updates

This release builds etcd with go v1.26.10 which fixes [multiple security issues found in Go](https://github.com/golang/go/issues?q=%28milestone%3AGo1.26.9+OR+milestone%3AGo1.27.2%29+label%3ACherryPickApproved):  CVE-2026-97032, CVE-2026-78659, CVE-2026-97031, CVE-2026-94440, CVE-2026-56866, CVE-2026-94439, CVE-2026-78669, CVE-2026-56857, CVE-2026-78667, and CVE-2026-78663.   This version also distrusts the [compromised eMudhra certificates](https://emudhra.we-have-a-problem.com/).

In addition, the following security fixes are included in this release:

- Update `golang.org/x/net` to v0.61.0 to address GO-2026-6617 (CVE-2026-97032), GO-2026-6612 (CVE-2026-78663), GO-2026-6611 (CVE-2026-78669) and GO-2026-6603 (CVE-2026-78659)
- Update `go.opentelemetry.io/otel/sdk`, `go.opentelemetry.io/otel/exporters/otlp/otlptrace` and `go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc` to v1.45.0 to address GO-2026-6505 (CVE-2026-81870)
- Update `klauspost/compress` to address [CVE-2026-63209](https://github.com/advisories/GHSA-259r-337f-4rfw)
- Update `golang.org/x/crypto 0.57.0` to v0.57.0 to address CVE-2026-56855 and CVE-2026-78662

That last security vulnerability was reported by contributor [lwescheq](https://github.com/lwescheq).  We are grateful for reports of security vulnerabilities; if you find one in etcd, please [report it using the form](https://github.com/etcd-io/etcd/security/advisories/new).

## Bug Fixes

This release fixes two regressions in v3.7, [sending MsgApp messages in reverse order](https://github.com/etcd-io/etcd/issues/22483) and a [data race in keys-only RangeStream](https://github.com/etcd-io/etcd/pull/22601).

As his first etcd contribution, Shubham Agrawal at UC Berkeley fixed another [potential data race in all versions](https://github.com/etcd-io/etcd/pull/22609).  This release also [prevents a panic in v3.6](https://github.com/etcd-io/etcd/pull/22542) from mistyping Lease ID. We've also marked the obsolete [`logutil.NewJournalWriter` as deprecated](https://github.com/etcd-io/etcd/pull/22530) in our code, so that it can be removed in v3.8.

For the full list of changes, please see the changelogs:

- [v3.7](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md)
- [v3.6](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.6.md)
- [v3.5](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md)
