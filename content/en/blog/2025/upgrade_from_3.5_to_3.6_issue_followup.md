---
title: Follow Up - Preventing Upgrade Failures from etcd v3.5 to v3.6
author:  "[Benjamin Wang](https://github.com/ahrtr) VMware by Broadcom, [Josh Berkus](https://github.com/jberkus) Red Hat"
date: 2025-10-21
draft: false
---

We have identified and fixed an additional scenario that may cause upgrade failures when
moving from etcd v3.5 to v3.6. This post contains details, the fix, and additional workarounds.
Please refer to issue [20793][] to get detailed technical information.

## Issue

In a previous post — [How to Prevent a Common Failure when Upgrading etcd v3.5 to v3.6][] — we
described an upgrade issue affecting etcd versions in v3.5.1-v3.5.19. That issue was addressed in
v3.5.20. However, a follow-up investigation revealed that the original fix did not cover all scenarios.

Specifically, during rolling replacement upgrades (such as those performed by Cluster API when upgrading
Kubernetes control planes), a new learner may receive a snapshot from an older member (≤ v3.5.19) containing
incorrect membership data. This inconsistency does not affect clusters still on v3.5 – where v2store remains
authoritative – but can cause upgrade failures when moving to v3.6, as a new learner may again receive a
snapshot with incorrect membership data and v3store becomes the source of truth.

## Solution

This additional scenario has been addressed in etcd v3.5.24 via [20797][].  All users who can
should first upgrade to etcd v3.5.24 (or a higher patch version) before upgrading to etcd v3.6;
otherwise, the upgrade may fail.

## Workarounds

Upgrading directly to v3.5.24 or later is the most reliable and simplest way of avoiding the upgrade failure.
However, if you cannot upgrade to v3.5.24 (or a higher patch version) for some reason, please apply
one of the following workarounds before upgrading to v3.6:

- If you are already running v3.5.20 - v3.5.23, restart all etcd members before upgrading to v3.6.x.
  - A full restart triggers re-registration and corrects the incorrect membership information.
- If you are already running v3.5.20 - v3.5.23, alternatively perform an additional upgrade to any patch version in v3.5.20 - v3.5.23.
  - Each member will re-register its server information, automatically correcting the incorrect membership data in the additional upgrade.
- If you are running v3.5.19 or earlier, upgrade to any version between v3.5.20 and v3.5.23, and then apply one of the two workarounds above.

## Acknowledgements

We would like to thank [Avinash Batukbhai][] from Broadcom for reporting the upgrade issue.
His report helped bring the issue to our attention so that we could investigate and resolve it upstream.

[20793]: https://github.com/etcd-io/etcd/issues/20793
[How to Prevent a Common Failure when Upgrading etcd v3.5 to v3.6]: https://etcd.io/blog/2025/upgrade_from_3.5_to_3.6_issue/
[20797]: https://github.com/etcd-io/etcd/pull/20797
[Avinash Batukbhai]: https://github.com/avinashsavaliya
