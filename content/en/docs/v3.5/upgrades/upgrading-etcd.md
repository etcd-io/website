---
title: Upgrading etcd clusters and applications
weight: 6500
description: Documentation list for upgrading etcd clusters and applications
---

This section contains documents specific to upgrading etcd clusters and applications.

## Upgrade policy

Before upgrading, note that etcd only supports the following two upgrade cases:

* **Patch upgrade:** Upgrading between patch releases within the same minor version (e.g. 3.5.23 - 3.5.26).
* **Minor upgrade:** Upgrading one minor version at a time (e.g. 3.4 - 3.5). Upgrades that skip a minor version are not supported and will likely fail. Update to the most recent patch version before upgrading to the next minor version.

## Upgrading an etcd v3.x cluster

* [Upgrade etcd from 3.0 to 3.1](../upgrade_3_1/)
* [Upgrade etcd from 3.1 to 3.2](../upgrade_3_2/)
* [Upgrade etcd from 3.2 to 3.3](../upgrade_3_3/)
* [Upgrade etcd from 3.3 to 3.4](../upgrade_3_4/)
* [Upgrade etcd from 3.4 to 3.5](../upgrade_3_5/)

## Upgrading from etcd v2.3

* [Upgrade a v2.3 cluster to v3.0](../upgrade_3_0/)
