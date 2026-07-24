---
# TODO(chalin): drop the `title` field once Hugo is fixed to use the site title
title: etcd
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
---

{{< blocks/cover image_anchor="top" height="min" color="primary" >}}
<img src="etcd-horizontal-white.png" class="site-logo" />
<h2 class="mt-4">
  A distributed, reliable key-value store for the most critical data of a distributed system
</h2>
<div class="mt-5 mx-auto">
	<a class="btn btn-lg btn-secondary mr-3 mb-4" href="/docs/{{< param latest_stable_version >}}/">
		Learn more
	</a>
	<a class="btn btn-lg btn-primary mr-3 mb-4" href="/docs/{{< param latest_stable_version >}}/quickstart">
		Quickstart<i class="fas fa-arrow-alt-circle-right ml-2"></i>
	</a>
</div>
{{< /blocks/cover >}}

{{% blocks/lead color="white" %}}
  <h1>What is etcd?</h1>
  <p>
    <b>etcd</b> is a strongly consistent, distributed key-value store that
    provides a reliable way to store data that needs to be accessed by a
    distributed system or cluster of machines. It gracefully handles leader
    elections during network partitions and can tolerate machine failure, even
    in the leader node.
    <a href="/docs/{{< param latest_stable_version >}}/">Learn more<i class="fas fa-arrow-alt-circle-right ml-2"></i></a>
  </p>
{{% /blocks/lead %}}

<div class="container">
  {{< home/features >}}
  {{< home/used-by >}}
  {{< home/cncf >}}
</div>
