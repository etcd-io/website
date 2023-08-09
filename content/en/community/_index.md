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
      [<i class="fab fa-google"></i>Google Meet][online]
    desc: >
      Join contributors and maintainers [online][], every two weeks.
  - title: >
      [<i class="fas fa-file-alt"></i>Meeting doc][meeting-doc]
    desc: >
      For meeting details, consult the [etcd community meeting][meeting-doc] document.
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

## Community meetings

etcd contributors and maintainers meet [online][] every two weeks, on **Thursday
at 11 AM** [Pacific Time][].

For phone-in information, the date of the next meeting, and minutes from past
meetings, see [etcd community meeting][meeting-doc].

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
[How to contribute]: https://github.com/etcd-io/etcd/blob/main/CONTRIBUTING.md
[meeting-doc]: https://docs.google.com/document/d/16XEGyPBisZvmmoIHSZzv__LoyOeluC5a4x353CX0SIM
[online]: https://zoom.us/my/cncfetcdproject
[Pacific Time]: https://www.timeanddate.com/time/zones/pt
[GD]: https://github.com/etcd-io/etcd/discussions
