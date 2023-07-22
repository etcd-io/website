---
title: Supported platforms
weight: 4800
description: etcd support for common architectures & operating systems
---

## Support tiers

etcd runs on different platforms, but the guarantees it provides depends on a
platform's support tier:

- **Tier 1**: fully supported by [etcd maintainers][]; etcd is guaranteed to
  pass all tests including functional and robustness tests.
- **Tier 2**: etcd is guaranteed to pass integration and end-to-end tests but
  not necessarily functional or robustness tests.
- **Tier 3**: etcd is guaranteed to build, may be lightly tested (or not), and
  so it should be considered _unstable_.

## Current support

The following table lists currently supported platforms and their corresponding
etcd support tier:

| Architecture | Operating system | Support tier |     Maintainers      |
|:------------:|:----------------:|:------------:|:--------------------:|
| AMD64        | Linux            |      1       | [etcd maintainers][] |
| ARM64        | Linux            |      1       | [etcd maintainers][] |
| AMD64        | Darwin           |      3       |                      |
| AMD64        | Windows          |      3       |                      |
| ARM          | Linux            |      3       |                      |
| 386          | Linux            |      3       |                      |
| ppc64le      | Linux            |      3       |                      |
| s390x        | Linux            |      3       |                      |

Unlisted platforms are unsupported.

## Supporting a new platform

Want to contribute to etcd as the "official" maintainer of a new platform? In
addition to committing to support the platform, you must setup etcd continuous
integration (CI) satisfying the following requirements, depending on the support
tier:

| etcd continuous integration           | Tier 1 | Tier 2 | Tier 3 |
| ------------------------------------- |:------:|:------:|:------:|
| Build passes                          | &check;| &check;| &check;|
| Unit tests pass                       | &check;| &check;|        |
| Integration and end-to-end tests pass | &check;| &check;|        |
| Robustness tests pass                 | &check;|        |        |

For an example of setting up tier-2 CI for ARM64, see [etcd PR #12928][].

## Unsupported platforms

To avoid inadvertently running an etcd server on an unsupported platform, etcd
prints a warning message and exits immediately unless the environment variable
`ETCD_UNSUPPORTED_ARCH` is set to the target architecture.

{{% alert title="32-bit systems" color="warning" %}}
  etcd has **known issues** on 32-bit systems due to a bug in the Go runtime.
  For more information see the [Go issue #599][go-issue] and the [atomic package
  bug note][go-atomic].

  [go-atomic]: https://golang.org/pkg/sync/atomic/#pkg-note-BUG
  [go-issue]: https://github.com/golang/go/issues/599
{{% /alert %}}

[etcd maintainers]: https://github.com/etcd-io/etcd/blob/master/MAINTAINERS
[etcd PR #12928]: https://github.com/etcd-io/etcd/pull/12928
