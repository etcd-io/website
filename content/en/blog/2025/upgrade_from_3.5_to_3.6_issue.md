---
title: How to Prevent a Common Failure when Upgrading etcd v3.5 to v3.6
author:  "[Benjamin Wang](https://github.com/ahrtr), VMware by Broadcom"
date: 2025-03-27
draft: false
---

{{% alert title="Update (October 21, 2025)" %}}
We have identified and fixed an additional scenario related to this issue. Please see our
new blog post
[Follow Up - Preventing Upgrade Failures from etcd v3.5 to v3.6](/blog/2025/upgrade_from_3.5_to_3.6_issue_followup)
for details.
{{% /alert %}}

There is a common issue [19557][] in the etcd v3.5 to v3.6 upgrade that may cause the upgrade
process to fail. You can find detailed information and related discussions in the issue.

## TL; DR

Users are required to first upgrade to etcd v3.5.20 (or a higher patch version) before upgrading
to etcd v3.6.0. Failure to do so may result in an unsuccessful upgrade.

## What's the symptom?

When upgrading a multi-member etcd cluster from a version between v3.5.1 and v3.5.19 to v3.6.0,
the upgrade may fail due to the error "`membership: too many learner member in cluster`".

## What's the root cause?

By default, etcd allows at most one learner member; the bootstrap process will fail if there are
two or more learners. Due to the issue [19557][], some voting members may revert to learners when
upgrading to v3.6.0, which may cause the upgrade to fail.

The root cause is that when promoting a learner, the related change is persistently stored in
v2store only, not in v3store. As a result, the membership data becomes inconsistent between
the v2store and v3store.

In etcd v3.5, the v2store is the source of truth for the membership data, whereas in etcd v3.6,
the v3store is the source of truth. It's exactly the reason why the issue only occurs when
upgrading from v3.5 to v3.6.

## Which versions are impacted?

The issue was introduced in etcd v3.5.1 via [13348][]. All etcd patch versions from v3.5.1 to
v3.5.19 are affected.

## Which versions contain the fix for this issue?

The issue was fixed in etcd v3.5.20 via [19563][]. **Therefore, users are required to first upgrade to
etcd v3.5.20 (or a higher patch version) before upgrading to etcd v3.6.0; otherwise, the
upgrade may fail.**

## What if users do not follow the guide?

What happens if users still upgrade directly from etcd v3.5.1-v3.5.19 to v3.6.0?

If the etcd cluster isn't affected by the issue, no members will revert to learners
during the upgrade. In this case, the upgrade will succeed without any problems.

If the etcd cluster has already been affected by the issue, there are two possible outcomes:

- If two or more members revert to learners during the upgrade, the upgrade will fail. In that
  case, users will have to roll back and first upgrade to etcd v3.5.20 (or a higher version)
  before attempting to upgrade to v3.6.0 again.
- If only one member reverts to a learner during the upgrade, the upgrade will still succeed.
  However, the issue is that a voting member reverts to a learner, which may confuse users and
  also affect the cluster's quorum. We addressed this issue in etcd v3.6.0-rc.3 via [19636][]
  by automatically promoting the learner to a voting member during bootstrap.

## How did we prevent this from happening again?

etcd has some end-to-end (e2e) upgrade test cases, but did not detect this issue. Instead,
it was discovered in Kubernetes' workflow test. To address this gap, we added a similar e2e
test via [19634][], which was also backported to release-3.6 via [19662][].

[19557]: https://github.com/etcd-io/etcd/issues/19557
[13348]: https://github.com/etcd-io/etcd/pull/13348
[19563]: https://github.com/etcd-io/etcd/pull/19563
[19636]: https://github.com/etcd-io/etcd/pull/19636
[19634]: https://github.com/etcd-io/etcd/pull/19634
[19662]: https://github.com/etcd-io/etcd/pull/19662
