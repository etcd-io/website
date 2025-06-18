---
title: etcd features
weight: 3750
description: using etcd features
---

This document provides an overview of etcd features to help users better understand the features and related deprecation process. If you are interested in knowing about how features are developed in the etcd, please see these [development guidelines](https://github.com/etcd-io/etcd/blob/main/Documentation/contributor-guide/features.md).

The etcd features fall into three stages, experimental, stable, and unsafe. You can get the list of features by running `etcd --help`.

## Experimental

In order to get early feedback, any new feature is usually added as an experimental feature. The experimental feature can be identified by looking at the flag name, which should have `--experimental` as a prefix. Please consider the following points while using an experimental feature: 
- It might be buggy due to a lack of user testing. Enabling the feature may not work as expected.
- It is disabled by default. 
- Support for such a feature may be dropped at any time without notice
    - It can be removed in the next minor or major release without following the [feature deprecation](#feature-deprecation) policy unless it graduates to a stable future.
    - The project team would appreciate users reporting any issues related to experimental features. However, such issues may be given lower priorities compared to the issues related to stable featuers.
- An experimental [feature flag deprecates](#feature-deprecation) when it graduates to the stable stage. Users should start using a stable feature flag as soon as possible.

## Stable

This is the most common stage of features in the etcd. A stable feature is characterized as below:
- Supported as part of the supported releases of etcd.
- May be enabled by default.
- Discontinuation of support must follow the [feature deprecation](#feature-deprecation) policy.

## Unsafe

Unsafe features are rare and listed under the `Unsafe feature:` section in the etcd usage documentation. By default, they are disabled. They should be used with caution following documentation. An unsafe feature can be removed in the next minor or major release without following the feature deprecation policy.

## Feature Deprecation

### Experimental
An experimental feature deprecates when it graduates to the stable stage.
- The experimental feature documentation will show a deprecation message with a recommendation to use a related stable feature flag. e.g. `DEPRECATED. Use <feature-name> instead.`
- A deprecated feature will be removed in the following release.

### Stable
As the project evolves, a stable feature may sometimes need to be deprecated and removed. When that happens, 
- The feature documentation will show a warning message before a planned release for deprecation. e.g. `To be deprecated in <release>.`.  If a new feature is already planned to replace the `To be deprecated` feature, then the documentation will also provide a message saying so. e.g. `Use <feature-name> instead.`.
- The feature will be deprecated in the planned release. At that time, the feature documentation will show a deprecation message with a recommendation to use a related stable feature. e.g. `DEPRECATED. Use <feature-name> instead.`
- A deprecated feature will be removed in the following release.
