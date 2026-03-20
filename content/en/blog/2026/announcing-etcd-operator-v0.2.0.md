---
title: Announcing etcd-operator v0.2.0
author:  "WG etcd-operator Organizers"
date: 2026-03-20
draft: false
---

## Introduction

Today, we are excited to announce the release of [etcd-operator v0.2.0]! This release brings important
new features and improvements that enhance security, reliability, and operability for managing etcd clusters.

## New Features

### Certificate Management

Version 0.2.0 introduces built-in certificate management to secure all TLS communication:

- Between etcd members (inter-member communication)
- Between clients and etcd members

TLS is only configured when explicitly enabled by the user. Once enabled, etcd-operator automatically
provisions and manages certificates based on the selected provider.

Currently, two providers are supported:

- **Auto** – Designed for development and testing environments
- **Cert-Manager** – Recommended for production use

If TLS is enabled but no provider is specified, the operator defaults to the **Auto** provider.

This feature simplifies secure cluster setup and reduces the operational overhead of managing certificates manually.

### Upgrade Support

etcd-operator now supports upgrading etcd clusters.

The operator follows the same upgrade rules as the main etcd project. Supported upgrade paths include:

- **Patch upgrades**: Between patch versions within the same minor version
  *(e.g., 3.6.0 → 3.6.2)*

- **Minor upgrades**: One minor version at a time
  *(e.g., 3.5 → 3.6)*

Skipping minor versions is not supported and may result in failure. It is recommended to upgrade to the
latest patch version before moving to the next minor version.

If you are using official etcd images, the operator will validate the upgrade path and enforce these rules automatically.

However, if you are using custom etcd image tags that do not follow Semantic Versioning, no validation will be performed.
In such cases, you are responsible for ensuring that the upgrade path is valid.

## Improvements in End-to-End Testing

We have made significant improvements to our end-to-end (e2e) testing:

- Integrated **gofail** to simulate failure scenarios
- Added additional test cases to better cover edge and exceptional conditions

These enhancements improve the robustness and reliability of the operator.

## Acknowledgements

This release would not have been possible without contributions from the community.
We’d like to give credit to all etcd-operator contributors.

We’re excited about this release and look forward to your feedback and contributions.

[etcd-operator v0.2.0]: https://github.com/etcd-io/etcd-operator/releases/tag/v0.2.0
