---
title: About
---
{{< blocks/cover image_anchor="top" height="sm" color="primary" >}}
{{< page/header >}}
{{< /blocks/cover >}}

<div class="container l-container--padded">

<div class="row">
{{< page/toc collapsed=true placement="inline" >}}
</div>

<div class="row">
<div class="col-12 col-lg-8">

## What is etcd?

**etcd** is a strongly consistent, distributed key-value store that provides a
reliable way to store data that needs to be accessed by a distributed system or
cluster of machines. It gracefully handles leader elections during network
partitions and can tolerate machine failure, even in the leader node.

Applications of any complexity, from a simple web app to [Kubernetes][], can
read data from and write data into etcd.

Your applications can read from and write data into etcd. A simple use case is
storing database connection details or feature flags in etcd as key-value pairs.
These values can be watched, allowing your app to reconfigure itself when they
change. Advanced uses take advantage of etcd's consistency guarantees to
implement database leader elections or perform distributed locking across a
cluster of workers.

etcd is open source, available <a href="https://github.com/etcd-io/etcd">on
GitHub</a>, and backed by the <a href="https://cncf.io">Cloud Native Computing
Foundation</a>.

## Technical overview

<p>etcd is written in <a href="https://golang.org">Go</a>. Communication between etcd machines is handled via the Raft consensus algorithm.</p>
<p>Latency from the etcd leader is the most important metric to track and the built-in dashboard has a view dedicated to this. In our testing, severe latency will introduce instability within the cluster because Raft is only as fast as the slowest machine in the majority. You can mitigate this issue by properly tuning the cluster. etcd has been pre-tuned on cloud providers with highly variable networks.</p>

[Kubernetes]: https://kubernetes.io

</div>

{{< page/toc placement="sidebar" >}}

</div>

{{< page/page-meta-links >}}

</div>
