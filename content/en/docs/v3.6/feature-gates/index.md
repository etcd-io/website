---
title: Feature Gates
weight: 10
content_type: concept
card:
  name: reference
  weight: 60
---

<!-- overview -->
This page contains an overview of the various feature gates an administrator
can specify on ETCD.

See [feature stages](#feature-stages) for an explanation of the stages for a feature.


<!-- body -->
## Overview

Feature gates are a set of key=value pairs that describe ETCD features.
You can turn these features on or off using the `--feature-gates` command line flag
on ETCD.

ETCD lets you enable or disable a set of feature gates that
are relevant to that component.
Use `-h` flag to see a full set of feature gates for all components.
To set feature gates for a component, such as kubelet, use the `--feature-gates`
flag assigned to a list of feature pairs:

```shell
--feature-gates=...,DistributedTracing=true
```

The following tables are a summary of the feature gates that you can set on
ETCD.

### Feature gates for Alpha or Beta features

| Feature                          | Default | Stage |
|----------------------------------|---------|-------|
| DistributedTracing               | false   | Alpha |
| StopGRPCServiceOnDefrag          | false   | Alpha |
| InitialCorruptCheck              | false   | Alpha |
| CompactHashCheck                 | false   | Alpha |
| TxnModeWriteWithSharedBuffer     | true    | Beta  |

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

* Usually enabled by default.
* The feature is well tested. Enabling the feature is considered safe.
* Support for the overall feature will not be dropped, though details may change.
* The schema and/or semantics of objects may change in incompatible ways in a
  subsequent beta or stable release. When this happens, we will provide instructions
  for migrating to the next version. This may require deleting, editing, and
  re-creating API objects. The editing process may require some thought.
  This may require downtime for applications that rely on the feature.
* Recommended for only non-business-critical uses because of potential for
  incompatible changes in subsequent releases. If you have multiple clusters
  that can be upgraded independently, you may be able to relax this restriction.

{{< note >}}
Please do try *Beta* features and give feedback on them!
After they exit beta, it may not be practical for us to make more changes.
{{< /note >}}

A *General Availability* (GA) feature is also referred to as a *stable* feature. It means:

* The feature is always enabled; you cannot disable it.
* The corresponding feature gate is no longer needed.
* Stable versions of features will appear in released software for many subsequent versions.

## List of feature gates {#feature-gates}

Each feature gate is designed for enabling/disabling a specific feature.

* `DistributedTracing`: Enable experimental distributed tracing using OpenTelemetry Tracing.
* `StopGRPCServiceOnDefrag`: Enable etcd gRPC service to stop serving client requests on defragmentation.
* `TxnModeWriteWithSharedBuffer`: Enables the write transaction to use a shared buffer in its readonly check operations.
* `InitialCorruptCheck`: Enable to check data corruption before serving any client/peer traffic.
* `CompactHashCheck`: Enable leader to periodically check followers compaction hashes.
