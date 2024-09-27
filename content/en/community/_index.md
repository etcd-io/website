---
title: Community
description: Welcome to the etcd user and developer community page
spelling: cSpell:ignore grpcio grpcmeetings subreddit youtube
main_channels:
  - title: >
      [<i class="fab fa-google"></i>Google Group][etcd-dev]
    desc: >
      Join the [etcd-dev][] forum to ask questions and get the latest etcd news.
  - title: >
      [<i class="fab fa-twitter"></i>Twitter][@etcdio]
    desc: >
      Follow us at [@etcdio][] for real-time announcements, blogs posts, and more.
  - title: >
      [<i class="fab fa-github"></i>Github Discussions][GD]
    desc: >
      Ask and find answers to your etcd questions.
community_resources:
  - title: >
      [<i class="fab"></i>Zoom Meeting][online]
    desc: >
      Join contributors and maintainers [online][], every two weeks.
  - title: >
      [<i class="fas fa-file-alt"></i>Meeting docs][community-meeting-doc]
    desc: >
      For meeting details, consult the [etcd community meeting][community-meeting-doc] and [robustness tests meeting][robustness-tests-meeting-doc] documents.
  - title: >
      [<i class="fab fa-youtube"></i>YouTube][etcd-youtube]
    desc: >
      Missed a meeting? No problem. See the [etcd channel][etcd-youtube] for
      meeting videos.
menu:
  main:
---

{{< blocks/cover color="primary" height="sm" >}}
{{< page/header >}}
{{< /blocks/cover >}}

<div class="container l-container--padded">

<div class="row">
{{< page/toc collapsed=true placement="inline" >}}
</div>

<div class="row">
<div class="col-12 col-lg-8">

{{% alert color="success" %}}
  <i class='fas fa-users mr-1'></i> Our community values respect and
  inclusiveness. We enforce our [Code of Conduct][] in all interactions.

  [Code of Conduct]: https://github.com/cncf/foundation/blob/master/code-of-conduct.md
{{% /alert %}}

## Join the conversation

Follow these active channels for timely announcements, and sign up to ask
questions:

{{% cards "main_channels" %}}

You can also chat with other etcd users and contributors in the #sig-etcd slack
channel on [Kubernetes Slack][].

## Meeting schedule

Please refer to [the Kubernetes community](https://github.com/kubernetes/community/blob/master/sig-etcd/README.md#meetings) SIG etcd summary for the latest updates to etcd community meeting schedules.

### Community meetings & Issue triage

etcd contributors and maintainers meet [online][] every week, on **Thursday
at 11 AM** [Pacific Time][], alternating between community meetings and issue
triage meetings. Issue triage meetings are aimed at getting through our backlog
of PRs and Issues. Triage meetings are open to any contributor; you don't have
to be a reviewer or approver to help out! They can also be a good way to get
started contributing.

For phone-in information, the date of the next meeting, minutes from past
meetings, and meeting recordings, see [etcd community meeting doc][community-meeting-doc].

### Operator working group

Join the [etcd operator working group](https://github.com/kubernetes/community/tree/master/wg-etcd-operator) for discussions on the development and management of the etcd operator. These meetings are held biweekly and are open to all community members who wish to contribute or stay informed about the project.

**Meeting Schedule:**

- **Biweekly** on **Tuesdays at 11 AM** [Pacific Time][].

**Zoom Details:**
For phone-in information, the date of the next meeting, minutes from past
meetings, and meeting recordings, see
[etcd operator working group meeting doc][operator-wg-doc].

### Robustness tests

Join us for a collaborative exploration of etcd's correctness under pressure
[online][] **biweekly**, on **Wednesday at 8 AM** [Pacific Time][]. Our goals are
to demystify distributed system testing by sharing knowledge and fostering a robust
testing culture within the etcd community, as well as to expand expertise by mentoring
new reviewers and approvers for etcd robustness tests. We invite community members to
propose items for the meetings.

For phone-in information, the date of the next meeting, minutes from past
meetings, and meeting recordings, see [etcd robustness tests meeting doc][robustness-tests-meeting-doc]
and [robustness tests meeting recordings][robustness-tests-meeting-recordings].

{{% cards "community_resources" %}}

## Contributing

Your contributions to etcd code and documentation are welcome! If you find a
problem or would like an enhancement, create an issue -- or better yet, consider
submitting a pull request.

For etcd contribution guidelines, see [How to contribute][].

</div>

{{< page/toc placement="sidebar" >}}

</div>

{{< page/page-meta-links >}}

</div>

[@etcdio]: https://twitter.com/etcdio
[etcd-dev]: https://groups.google.com/g/etcd-dev
[etcd-youtube]: https://www.youtube.com/channel/UC7tUWR24I5AR9NMsG-NYBlg
[robustness-tests-meeting-recordings]: https://www.youtube.com/playlist?list=PLRGL688DpO9oF-YEEfVXMzaOUzFYK74-I
[How to contribute]: https://github.com/etcd-io/etcd/blob/main/CONTRIBUTING.md
[community-meeting-doc]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM
[robustness-tests-meeting-doc]: https://docs.google.com/document/d/1idZ_7tV6F18v223LyQ0WVUn9gXLSKyeLwYTdAgbjxpw/edit?usp=sharing
[online]: https://zoom.us/my/cncfetcdproject
[Pacific Time]: https://www.timeanddate.com/time/zones/pt
[GD]: https://github.com/etcd-io/etcd/discussions
[Kubernetes Slack]: https://slack.k8s.io
[operator-wg-doc]: https://docs.google.com/document/d/1ey4zTTRvtCVJJP2vjF95VjG-sAKlNTcqB2HdmC18Lfc/edit?usp=sharing
