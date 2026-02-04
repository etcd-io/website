---
title: Upgrading
weight: 6000
description: Upgrading etcd clusters and applications
---

## Supported upgrade path

etcd only supports upgrades in the following two cases:

- Upgrading between patch releases within the same minor version.
- Upgrading from the current version to the next minor version, or to the next major
version, if the current minor version is the last minor of the current major.
