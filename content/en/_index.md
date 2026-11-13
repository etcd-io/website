---
# TODO(chalin): drop the `title` field once Hugo is fixed to use the site title
title: etcd
# Rendered by layouts/home.html. Button links are /docs/<latest_stable_version>/<docs_path>.
cover:
  logo: https://raw.githubusercontent.com/cncf/artwork/main/projects/etcd/horizontal/white/etcd-horizontal-white.svg
  tagline: A distributed, reliable key-value store for the most critical data of a distributed system
  buttons:
    - text: Learn more
      style: secondary
      docs_path: ""
    - text: Quickstart
      style: primary
      docs_path: quickstart
      icon: fas fa-arrow-alt-circle-right
features:
  - title: Simple interface
    description: Read and write values using standard HTTP tools, such as curl
    icon: interface.svg
  - title: Key-value storage
    description: Store data in hierarchically organized directories, as in a standard filesystem
    icon: kv.svg
  - title: Watch for changes
    description: Watch specific keys or directories for changes and react to changes in values
    icon: watch.svg
# Heading of the lead section below; the Markdown body is its text.
lead_title: What is etcd?
---

**etcd** is a strongly consistent, distributed key-value store that
provides a reliable way to store data that needs to be accessed by a
distributed system or cluster of machines. It gracefully handles leader
elections during network partitions and can tolerate machine failure, even
in the leader node.
[Learn more](/docs/{{< param latest_stable_version >}}/)
