---
title: etcd v3.7.0-rc.0 Now Available for Testing
author:  "SIG-Etcd Leads"
date: 2026-06-01
draft: false
---

SIG-Etcd announces the availability of etcd v3.7.0-rc.0, the first release candidate for the upcoming etcd v3.7.0 release.

This release candidate includes the long-requested RangeStream feature, removal of remaining legacy v2store components, protobuf refactoring, dependency updates, and performance improvements for large read workloads. It is not the final v3.7.0 release yet. The project is asking users and downstream projects to test this release candidate and report any issues before the final release.

You can find etcd v3.7.0-rc.0 here:

* [Source code](https://github.com/etcd-io/etcd/archive/refs/tags/v3.7.0-rc.0.tar.gz)
* [Binaries](https://github.com/etcd-io/etcd/releases/download/v3.7.0-rc.0/etcd-v3.7.0-rc.0-linux-amd64.tar.gz)
* [Official container images](https://gcr.io/etcd-development/etcd)

Note that for v3.7, only [multi-arch container images](https://github.com/etcd-io/etcd/pull/21840) will be available.  We will no longer be releasing container images with architecture tags in their names. Please adjust your pull commands accordingly.

Please try it out and report issues in the [etcd repository](https://github.com/etcd-io/etcd/issues).

In addition to all of the features from the [etcd v3.7.0-beta.0 release](https://etcd.io/blog/2026/etcd-370-beta/), the following additional changes are available in this release:
Keys-only Range optimization

etcd v3.7.0-rc.0 includes a [keys-only Range optimization](https://github.com/etcd-io/etcd/pull/21791 ). When a Range request uses `--keys-only`, etcd can avoid reading values from bbolt in cases where values are not needed, and return keys using data already available from the in-memory index.

This reduces unnecessary backend reads and memory use for workloads that only need key names, making large keys-only range requests more efficient.
Protobuf Refactoring
v3.7 migrates and replaces multiple outdated protobuf libraries with fully supported dependencies.  Along with related changes, this includes [replacing `github.com/golang/protobuf` and `github.com/gogo/protobuf`](https://github.com/etcd-io/etcd/issues/14533) with the fully-supported `google.golang.org/protobuf`, and  migrating [`grpc-logging` to `grpc-middleware v2`](https://github.com/etcd-io/etcd/pull/20420).

While these changes are not expected to directly affect users running etcd via official binaries or container images, they may affect users who depend on etcd Go modules, such as the client SDK or packages under api/ or pkg/. These consumers may need to update their code or dependencies due to protobuf and related API changes introduced in this release. More detailed information is available from [the API change tracking issue](https://github.com/etcd-io/website/issues/1162).
Other updates

etcd v3.7.0-rc.0 also includes [bbolt v1.5.0](https://github.com/etcd-io/bbolt/releases/tag/v1.5.0-rc.0), [raft v3.7.0](https://github.com/etcd-io/raft/releases/tag/v3.7.0-rc.1), Unix socket support, faster and more reliable leases, timeouts for `etcdutl` commands, and many other improvements.

For the full list of changes, see the [etcd v3.7 changelog](https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md).
Testing and feedback

Release candidates are intended for testing before the final release. Users should test etcd v3.7.0-rc.0 in non-production environments and report any problems they find.

Feedback can be shared through:

* [GitHub issues](https://github.com/etcd-io/etcd/issues)
* [#SIG-etcd slack channel](https://kubernetes.slack.com/archives/C3HD8ARJ5) in [Kubernetes Slack](https://www.kubernetes.dev/docs/comms/slack/#joining-slack)
* [etcd-dev mailing list](https://groups.google.com/g/etcd-dev)

There may be additional release candidates if required to test substantial fixes. SIG-etcd plans to release v3.7.0 in late June to early July.

Thank you to all contributors, reviewers, and users helping test this release.
