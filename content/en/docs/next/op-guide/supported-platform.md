---
title: Supported systems
weight: 4800
description: etcd support status for common architectures & operating systems
---

## Current support

The following table lists etcd support status for common architectures and operating systems:

| Architecture | Operating System | Support Tier | Maintainers                 |
| ------------ | ---------------- | ------------ | --------------------------- |
| amd64        | Linux            | Tier-1       | etcd maintainers            |
| arm64        | Linux            | Tier-2       | @gyuho, @glevand            |
| amd64        | Darwin           | Tier-3       |                             |
| amd64        | Windows          | Tier-3       |                             |
| arm          | Linux            | Tier-3       |                             |
| 386          | Linux            | Tier-3       |                             |
| ppc64le      | Linux            | Tier-3       | @mkumatag                   |

*etcd-maintainers are listed in [MAINTAINERS](https://github.com/etcd-io/etcd/blob/master/MAINTAINERS).*

Tier-1 platforms are fully supported by etcd maintainers and required to pass all tests including functional tests. Tier-2 platforms appear to work in practice but may have some platform specific code in etcd and not fully conform to the stable support policy. To qualify for Tier-2, the platform must pass integration and end-to-end tests in CI (see [github PR](https://github.com/etcd-io/etcd/pull/12928) for adding arm64). Tier-3 platforms or unlisted architectures are either lightly tested or have no testing in place, thus unstable and currently unsupported; caveat emptor.

## Supporting a new system platform

For etcd to officially support a new platform as stable, a few requirements are necessary to ensure acceptable quality:

1. An "official" maintainer for the platform with clear motivation; someone must be responsible for taking care of the platform.
2. Set up CI for build; etcd must compile. **Requirements for Tier-3**.
3. Set up CI for running unit tests; etcd must pass simple tests.
4. Set up CI for running integration and end-to-end tests. **Requirements for Tier-2**.
5. Set up CI for functional tests, and an etcd cluster should survive stress testing. **Requirements for Tier-1**.

## 32-bit and other unsupported systems

etcd has known issues on 32-bit systems due to a bug in the Go runtime. See the [Go issue][go-issue] and [atomic package][go-atomic] for more information.

To avoid inadvertently running a possibly unstable etcd server, `etcd` on unstable or unsupported architectures will print a warning message and immediately exit if the environment variable `ETCD_UNSUPPORTED_ARCH` is not set to the target architecture.

Currently amd64 and ppc64le architectures are officially supported by `etcd`.

[go-atomic]: https://golang.org/pkg/sync/atomic/#pkg-note-BUG
[go-issue]: https://github.com/golang/go/issues/599
