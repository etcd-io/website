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

  [Code of Conduct]: https://www.kubernetes.dev/community/code-of-conduct/
{{% /alert %}}

## Join the conversation

Follow these active channels for timely announcements, and sign up to ask
questions:

{{% cards "main_channels" %}}

You can also chat with other etcd users and contributors in the #sig-etcd slack
channel on [Kubernetes Slack][].

## Meeting schedule

Subscribe to the SIG-etcd calendar for a schedule of all our meetings.  Calendar ID: `be23e1c372820ae5667fad118d1a7a9fd80b5ec75573ae656b3a4bd74fd47193@group.calendar.google.com`

Most meetings have shared agendas and notes as part of the [SIG-etcd meetings doc][community-meeting-doc].  To access the notes doc, you first need to subscribe to [etcd-dev][].  **Zoom passcodes are on the meeting doc**.

Please refer to [the Kubernetes community][] SIG etcd summary for additional information on etcd community meeting schedules.

### Community meeting

* *Purpose*: general development discussion for etcd
* *Schedule*: every other week, Thursday, 11 AM [Pacific Time][]
* *Notes*: [Community Meeting Notes][]
* *Zoom*: [SIG-etcd Zoom][online]

If you're new to etcd, this meeting is probably the place to start!  It's also where you should bring proposals of new features or major project changes, or follow-ups on PR reviews.

### Issue triage

* *Purpose*: clear issue and PR backlog
* *Schedule*: every other week, Thursday, 11 AM [Pacific Time][]
* *Notes*: [Triage Meeting Notes][]
* *Zoom*: [SIG-etcd Zoom][online]

Issue triage meetings alternate weeks with the Community Meeting.  They are aimed at getting 
through our backlog of PRs and Issues. Triage meetings are open to any contributor; you 
don't have to be a reviewer or approver to help out! They can also be a good way to get
started contributing.

### Robustness tests

* *Purpose*: working meeting for robustness testing
* *Schedule*: every other week, Wednesday, 11 AM [Pacific Time][]
* *Notes*: [Robustness Meeting Notes][]
* *Zoom*: [SIG-etcd Zoom][online]

Join us biweekly for a collaborative exploration of etcd's correctness under pressure. Our goals are
to demystify distributed system testing by sharing knowledge and fostering a robust
testing culture within the etcd community, as well as to expand expertise by mentoring
new reviewers and approvers for etcd robustness tests. We invite community members to
propose items for the meetings.

### Documentation Meetings

* *Purpose*: Work on documentation, clear docs PRs, blog
* *Schedule*: every other week, Tuesday, 5:00 PM [Pacific Time][]
* *Notes*: [Documentation Meeting Notes][]
* *Zoom*: [SIG-etcd Zoom][online]

Want to help improve and expand etcd's documentation?  Have a feature that needs to be added to the docs?  Or maybe you want to write or edit a blog post.  We could use you.  This is also a good first meeting for you if you're in Australia, NZ, China, or Japan time zones.

### Operator working group

* *Purpose*: develop the new etcd operator
* *Schedule*: every other week, Tuesday, 11 AM [Pacific Time][]
* *Notes*: [WG-etcd-operator notes][operator-wg-doc]
* *Zoom*: [WG-etcd-operator Zoom][operator-zoom]

Join the [etcd operator working group][] for discussions on the development and management of the etcd operator. These meetings are held biweekly and are open to all community members who wish to contribute or stay informed about the project.

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
[Community Meeting Notes]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM/edit?tab=t.0#heading=h.txs5bihsv4q0
[Triage Meeting Notes]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM/edit?tab=t.xjc2zly8zbof#heading=h.eu3cetgrd3ii
[Documentation Meeting Notes]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM/edit?tab=t.gksuxl4c139h
[Robustness Meeting Notes]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM/edit?tab=t.v6ew634mcun0#heading=h.eu3cetgrd3ii
[online]: https://zoom.us/j/99252206415 
[Pacific Time]: https://www.timeanddate.com/time/zones/pt
[GD]: https://github.com/etcd-io/etcd/discussions
[Kubernetes Slack]: https://slack.k8s.io
[operator-wg-doc]: https://docs.google.com/document/d/1ey4zTTRvtCVJJP2vjF95VjG-sAKlNTcqB2HdmC18Lfc/edit?usp=sharing
[operator-zoom]: https://zoom.us/j/93758419981
[etcd operator working group]: https://github.com/kubernetes/community/tree/master/wg-etcd-operator
