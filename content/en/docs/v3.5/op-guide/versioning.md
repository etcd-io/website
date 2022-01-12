---
title: Versioning
weight: 4900
description: Versioning support by etcd
---

This document describes the versions supported by the etcd project.

## Service versioning and supported versions

etcd versions are expressed as **x.y.z**, where **x** is the major version, **y** is the minor version, and **z** is the patch version, following [Semantic Versioning](https://semver.org/) terminology.
New minor versions may add additional features to the API.

The etcd project maintains release branches for the current version and two minor releases, 3.5, 3.4 and 3.3 currently.

Applicable fixes, including security fixes, may be backported to those three release branches, depending on severity and feasibility.
Patch releases are cut from those branches when required.

The project [Maintainers](https://github.com/etcd-io/etcd/blob/main/MAINTAINERS) own this decision.

You can check the running etcd cluster version with `etcdctl`:

```sh
etcdctl --endpoints=127.0.0.1:2379 endpoint status
```

## API versioning

The `v3` API responses should not change after the 3.0.0 release but new features will be added over time.

