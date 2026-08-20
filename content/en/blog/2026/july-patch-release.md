---
title: "Etcd July Patch Releases: v3.5.32 and v3.6.13"
author:  "SIG-Etcd Leads"
date: 2026-07-01
draft: false
---

SIG-etcd has released routine patch updates for the v3.5 and v3.6 release branches.  These releases address dependency CVEs, fix a websocket authentication bug, and add a new option to help operators complete the v2 storage deprecation.  Users on v3.5 and v3.6 should update at the next scheduled maintenance window.

Obtain the updates here:

* [v3.6.13](https://github.com/etcd-io/etcd/releases/tag/v3.6.13)
* [v3.5.32](https://github.com/etcd-io/etcd/releases/tag/v3.5.32)

Official container images are available from [gcr.io](https://gcr.io/etcd-development/etcd).

As noted in the [June release](https://etcd.io/blog/2026/june-patch-release/), v3.4 reached end of support and will not receive any further patches.  If you are still running v3.4, please [upgrade to a supported version](https://etcd.io/docs/v3.6/upgrades/upgrade_3_5/) as soon as possible.

## Patching dependency CVEs

This release updates v3.5 and v3.6 to [golang v1.25.11](https://groups.google.com/g/golang-nuts), and bump `go.opentelemetry.io/otel` and `go.opentelemetry.io/otel/sdk` to `v1.43.0` to address security vulnerabilities in go, including [CVE-2026-29181](https://github.com/advisories/GHSA-mh2q-q3fh-2475) and [CVE-2026-39883](https://github.com/advisories/GHSA-hfvc-g4fc-pqhx). v3.6.13 additionally bumps `golang.org/x/crypto` to `v0.52.0` to resolve several CVEs.

It is unknown how many of these vulnerabilities are exploitable in etcd, but users should plan to apply the patch as soon as convenient regardless.

If you find a vulnerability in etcd, please report it [through the form on GitHub](https://github.com/etcd-io/etcd/security/advisories/new).

## Fixing websocket authentication with bearer-prefixed tokens

Both releases include a fix for [websocket authentication with bearer-prefixed auth tokens](https://github.com/etcd-io/etcd/pull/21932), which previously caused authenticated websocket requests to be rejected when the token included the `Bearer` prefix.

## New `write-only-skip-check` option for `--v2-deprecation`

Both releases add a new [`write-only-skip-check`](https://github.com/etcd-io/etcd/pull/21850) value for the `--v2-deprecation` flag. It behaves like `write-only`, but skips the startup check that would otherwise prevent etcd from starting when the v2 store contains custom (non-membership) data.

This option is intended for operators upgrading etcd from v3.5 to v3.6. Please review the [Upgrade etcd from v3.5 to v3.6](https://etcd.io/docs/v3.6/upgrades/upgrade_3_6/) guide before using it; the option is opt-in and should be used at the operator's own risk.  Note that `write-only-drop-data`, which wipes any remaining v2 data on startup, is planned to become the default in etcd v3.7, so `write-only-skip-check` gives operators a controlled path to handle v2 data on their own timeline before that change lands.

In addition, v3.5.32 enhances [`etcdutl check v2store`](https://github.com/etcd-io/etcd/pull/21889) to inspect both v2 snapshot and WAL records, so operators can audit exactly what v2 data remains before deciding whether to use `write-only-skip-check` or proceed with a full migration.

## Other improvements in v3.5.32

v3.5.32 backports the [`server: allow non-admin maintenance status`](https://github.com/etcd-io/etcd/pull/21811) change that previously shipped in v3.6.12, allowing non-admin users to call the maintenance `Status` endpoint.

This release also includes additional reliability fixes, which can be found in the full changelogs:

* [CHANGELOG-3.6](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.6.md#v3613)
* [CHANGELOG-3.5](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.5.md#v3532)
