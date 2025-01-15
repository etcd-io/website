---
title: Feature Gates
weight: 1175
content_type: concept
card:
  name: reference
  weight: 60
---

<!-- overview -->
This page contains an overview of the various feature gates an administrator
can specify on etcd.

See [feature stages](#feature-stages) for an explanation of the stages for a feature.

<!-- body -->
## Overview

Feature gates are a set of key=value pairs that describe etcd features.
You can turn these features on or off using the `--feature-gates` command line flag
on etcd.

etcd lets you enable or disable a set of feature gates.
Use `-h` flag to see a full set of feature gates.
To set feature gates, use the `--feature-gates` flag assigned to a list of feature pairs in commandline:

```shell
--feature-gates=...,StopGRPCServiceOnDefrag=true
```

Or specify `feature-gates` in YAML config file:

```shell
feature-gates: ...,StopGRPCServiceOnDefrag=true
```

The following tables are a summary of the feature gates that you can set on
etcd.

### Feature gates for Alpha or Beta features

| Feature                          | Default | Stage | Details                                                                              |
|----------------------------------|---------|-------|--------------------------------------------------------------------------------------|
| StopGRPCServiceOnDefrag          | false   | Alpha |Enables etcd gRPC service to stop serving client requests on defragmentation.         |
| InitialCorruptCheck              | false   | Alpha |Enables the write transaction to use a shared buffer in its readonly check operations.|
| CompactHashCheck                 | false   | Alpha |Enables to check data corruption before serving any client/peer traffic.              |
| TxnModeWriteWithSharedBuffer     | true    | Beta  |Enables leader to periodically check followers compaction hashes.                     |

## Using a feature

### Feature stages

A feature can be in *Alpha*, *Beta* or *GA* stage.
An *Alpha* feature means:

* Disabled by default.
* Might be buggy. Enabling the feature may expose bugs.
* Support for feature may be dropped at any time without notice.
* The API may change in incompatible ways in a later software release without notice.
* Recommended for use only in short-lived testing clusters, due to increased
  risk of bugs and lack of long-term support.

A *Beta* feature means:

* Enabled by default.
* The feature is well tested. Enabling the feature is considered safe.
* Support for the overall feature will not be dropped, though details may change.
* Recommended for only non-business-critical uses because of potential for
  discovering new hard-to-spot bugs through wider adoption.

**Note:**
Please do try *Beta* features and give feedback on them!
After they exit beta, it may not be practical for us to make more changes.

A *General Availability* (GA) feature is also referred to as a *stable* feature. It means:

* The feature is always enabled; you cannot disable it.
* The corresponding feature gate is no longer needed.
* Stable versions of features will appear in released software for many subsequent versions.

A *Deprecated* feature means:

* The feature gate is no longer in use.
* The feature has graduated to GA or been removed.
