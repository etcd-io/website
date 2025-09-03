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

### Change in `embed.EtcdServer` struct

In 3.6, field `ServerFeatureGate` is added to `embed.Config`, and should be replacing the experimental fields listed below:

```diff
package embed

type Config struct {
  // Deprecated: Use CompactHashCheck Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalCompactHashCheckEnabled bool `json:"experimental-compact-hash-check-enabled"`

  // Deprecated: Use InitialCorruptCheck Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalInitialCorruptCheck bool `json:"experimental-initial-corrupt-check"`

  // Deprecated: Use TxnModeWriteWithSharedBuffer Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalTxnModeWriteWithSharedBuffer bool `json:"experimental-txn-mode-write-with-shared-buffer"`

  // Deprecated: Use StopGRPCServiceOnDefrag Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalStopGRPCServiceOnDefrag bool `json:"experimental-stop-grpc-service-on-defrag"`

  // Deprecated: Use LeaseCheckpoint Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalEnableLeaseCheckpoint bool `json:"experimental-enable-lease-checkpoint"`
  
  // Deprecated: Use LeaseCheckpointPersist Feature Gate instead. Will be decommissioned in v3.7.
  ExperimentalEnableLeaseCheckpointPersist bool `json:"experimental-enable-lease-checkpoint-persist"`

+ // ServerFeatureGate is a server level feature gate
+ ServerFeatureGate featuregate.FeatureGate
  ...
```

### Feature gates for Alpha or Beta features

The following tables are a summary of the feature gates that you can set on
etcd.

| Feature                          | Default | Stage | Details                                                                               |
|----------------------------------|---------|-------|--------------------------------------------------------------------------------------|
| CompactHashCheck                 | false   | Alpha |Enables to check data corruption before serving any client/peer traffic.                                                                              |
| InitialCorruptCheck              | false   | Alpha |Enables leader to periodically check followers compaction hashes.                                                                           |
| LeaseCheckpoint                  | false   | Alpha |Enables leader to send regular checkpoints to other members to prevent reset of remaining TTL on leader change.                                              |
| LeaseCheckpointPersist           | false   | Alpha |Enables persisting remainingTTL to prevent indefinite auto-renewal of long lived leases.                                                                         |
| SetMemberLocalAddr               | false   | Alpha |Enables using the first specified and non-loopback local address from initial-advertise-peer-urls as the local address when communicating with a peer.      |
| StopGRPCServiceOnDefrag          | false   | Alpha |Enables etcd gRPC service to stop serving client requests on defragmentation.                                                                      |
| TxnModeWriteWithSharedBuffer     | true    | Beta  |Enables the write transaction to use a shared buffer in its readonly check operations.                                                                                |

## Using a feature

### Feature stages

A feature can be in *Alpha*, *Beta*, *GA* or *Deprecated* stage.
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
